defmodule Nookal.Client do
  @moduledoc false

  require Logger

  alias Nookal.{
    Connection,
    Uploader
  }

  @behaviour Nookal.Dispatcher

  @api_key Application.fetch_env!(:nookal, :api_key)
  @path_prefix "/production/v2"

  def start_link(endpoint_uri) do
    children = [
      Supervisor.child_spec({Connection, endpoint_uri}, %{id: Connection}),
      Supervisor.child_spec({Uploader, []}, %{id: Uploader})
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  def child_spec(endpoint_uri) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [endpoint_uri]}
    }
  end

  @impl true
  def dispatch(req_path, req_params \\ %{}) do
    req_body =
      req_params
      |> Map.put_new("api_key", @api_key)
      |> URI.encode_query()

    req_headers = [
      {"content-type", "application/x-www-form-urlencoded; charset=UTF-8"},
      {"content-length", Integer.to_string(byte_size(req_body))},
      {"accept", "application/json"}
    ]

    req_path = @path_prefix <> req_path

    case Connection.request("POST", req_path, req_headers, req_body) do
      {:ok, 200, _resp_headers, resp_body} ->
        handle_body(resp_body)

      {:ok, unexpected_status, _response_headers, resp_body} ->
        Logger.error(
          "Received unexpected response, status: " <>
            inspect(unexpected_status) <> ", body: " <> inspect(resp_body)
        )

        {:error, :request_failure}

      {:error, reason} ->
        Logger.error("Could not reach remote API, reason: " <> inspect(reason))

        {:error, :request_failure}
    end
  end

  @impl true
  def upload(file_uploading_url, file_content) do
    case Nookal.Uploader.upload(file_uploading_url, file_content) do
      {:ok, 200, _resp_headers, _resp_body} ->
        :ok

      {:ok, status, _resp_headers, resp_body} ->
        resp_body = IO.iodata_to_binary(resp_body)

        Logger.error(
          "Receive unexpected status from Amazon Web Service, status: " <>
            inspect(status) <> ", body: " <> resp_body
        )

        {:error, {:upload_failure, :unexpected_status}}

      {:error, _reason} = error ->
        error
    end
  end

  defp handle_body(resp_body) do
    case Jason.decode(resp_body) do
      {:ok, %{"status" => "failure"} = payload} ->
        %{"details" => %{"errorMessage" => error_message}} = payload

        {:error, {:api_failure, error_message}}

      {:ok, payload} ->
        {:ok, payload}

      {:error, _decode_error} ->
        Logger.error(["Could not decode response, body: " | resp_body])

        {:error, :decode_error}
    end
  end
end
