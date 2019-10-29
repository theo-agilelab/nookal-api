defmodule Nookal.Connection do
  @moduledoc false

  use Connection

  require Logger

  defstruct [:endpoint_uri, :conn, requests: %{}]

  @timeout 30_000

  def child_spec(endpoint_uri) do
    %{
      start: {__MODULE__, :start_link, [endpoint_uri]}
    }
  end

  def start_link(endpoint_uri) do
    Connection.start_link(__MODULE__, endpoint_uri, name: __MODULE__)
  end

  def init(endpoint_uri) do
    {:connect, :init, %__MODULE__{endpoint_uri: endpoint_uri}}
  end

  def request(method, path, headers, body) do
    Connection.call(__MODULE__, {:request, method, path, headers, body}, @timeout)
  end

  def connect(_info, state) do
    case connect(state.endpoint_uri) do
      {:ok, conn} ->
        {:ok, %{state | conn: conn}}

      {:error, :invalid_uri} ->
        {:stop, :invalid_uri, state}

      {:error, _reason} ->
        {:backoff, 1_000, state}
    end
  end

  defp connect(%URI{scheme: scheme, host: host, port: port})
       when scheme in ["http", "https"] do
    scheme
    |> String.to_existing_atom()
    |> Mint.HTTP.connect(host, port)
  end

  defp connect(_uri) do
    {:error, :invalid_uri}
  end

  def disconnect(_info, state) do
    {:ok, _conn} = Mint.HTTP.close(state.conn)

    state = %{state | conn: nil, requests: %{}}
    {:connect, :reconnect, state}
  end

  def handle_call({:request, method, path, headers, body, }, from, state) do
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = %{state | conn: conn}
        state = put_in(state.requests[request_ref], %{from: from, response: %{}})
        {:noreply, state}

      {:error, _conn, reason} ->
        {:disconnect, :request_failure, {:error, reason}, state}
    end
  end

  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        {:noreply, state}

      {:ok, conn, responses} ->
        state = Enum.reduce(responses, %{state | conn: conn}, &process_response/2)

        if Mint.HTTP.open?(conn) do
          {:noreply, state}
        else
          # Received GOAWAY message.
          Logger.warn("Disconnected with remote server")

          {:connect, :reconnect, %{state | requests: %{}, conn: nil}}
        end

      {:error, conn, reason, responses} ->
        Logger.error(
          "Encountered error when streaming responses, reason: " <> Exception.message(reason)
        )

        state = Map.replace!(state, :conn, conn)
        state = Enum.reduce(responses, state, &process_response/2)

        {:noreply, state}
    end
  end

  defp process_response({:status, request_ref, status}, state) do
    put_in(state.requests[request_ref].response[:status], status)
  end

  defp process_response({:headers, request_ref, headers}, state) do
    put_in(state.requests[request_ref].response[:headers], headers)
  end

  defp process_response({:data, request_ref, new_data}, state) do
    update_in(state.requests[request_ref].response[:body], fn data ->
      if data, do: [data | new_data], else: new_data
    end)
  end

  defp process_response({:error, request_ref, reason}, state) do
    {%{from: from}, state} = pop_in(state.requests[request_ref])

    GenServer.reply(from, {:error, {:request_failure, reason}})

    state
  end

  defp process_response({:done, request_ref}, state) do
    {%{response: response, from: from}, state} = pop_in(state.requests[request_ref])
    %{status: status, headers: headers} = response
    body = Map.get(response, :body, [])

    reply = {:ok, status, headers, body}
    GenServer.reply(from, reply)

    state
  end
end
