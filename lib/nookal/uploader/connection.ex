defmodule Nookal.Uploader.Connection do
  @moduledoc false

  use GenServer

  require Logger

  defstruct [:conn, :request_ref, :from, response: %{}]

  def start_link(_options) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(nil) do
    {:ok, %__MODULE__{}}
  end

  def upload(pid, uploading_url, file_content, timeout \\ 30_000) do
    GenServer.call(pid, {:upload, uploading_url, file_content}, timeout)
  end

  def handle_call({:upload, uploading_url, file_content}, from, state) do
    %URI{path: req_path, query: req_query} = uploading_uri = URI.parse(uploading_url)

    req_headers = []
    req_path = req_path <> "?" <> req_query

    with {:ok, conn} <- connect(uploading_uri),
         {:ok, conn, request_ref} <-
           Mint.HTTP.request(conn, "PUT", req_path, req_headers, file_content) do
      state = %{state | conn: conn, from: from, request_ref: request_ref}

      {:noreply, state}
    else
      {:error, _conn, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_info(message, %{from: from} = state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        {:noreply, state}

      {:ok, conn, responses} ->
        state = Enum.reduce(responses, %{state | conn: conn}, &process_response/2)

        {:noreply, state}

      {:error, conn, reason, _responses} ->
        Logger.error(
          "Encountered error when streaming responses, reason: " <> Exception.message(reason)
        )

        GenServer.reply(from, {:error, {:upload_failure, reason}})

        {:noreply, disconnect(conn)}
    end
  end

  defp process_response({:status, request_ref, status}, %{request_ref: request_ref} = state) do
    put_in(state.response[:status], status)
  end

  defp process_response({:headers, request_ref, headers}, %{request_ref: request_ref} = state) do
    put_in(state.response[:headers], headers)
  end

  defp process_response({:data, request_ref, new_data}, %{request_ref: request_ref} = state) do
    update_in(state.response[:body], fn data ->
      if data, do: [data | new_data], else: new_data
    end)
  end

  defp process_response({:error, _request_ref, reason}, %{from: from, conn: conn}) do
    GenServer.reply(from, {:error, {:upload_failure, reason}})

    disconnect(conn)
  end

  defp process_response({:done, request_ref}, %{request_ref: request_ref} = state) do
    %{response: response, from: from, conn: conn} = state
    %{status: status, headers: headers} = response

    body = Map.get(response, :body, [])

    GenServer.reply(from, {:ok, status, headers, body})

    disconnect(conn)
  end

  defp connect(%URI{scheme: scheme, host: host, port: port})
       when scheme in ["http", "https"] do
    scheme
    |> String.to_existing_atom()
    |> Mint.HTTP.connect(host, port)
  end

  defp disconnect(conn) do
    Mint.HTTP.close(conn)

    %__MODULE__{}
  end
end
