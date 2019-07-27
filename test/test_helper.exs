Application.load(:nookal)

:nookal
|> Application.spec(:applications)
|> Enum.each(&Application.ensure_all_started/1)

ExUnit.start()

Mox.defmock(Nookal.ClientMock, for: Nookal.Dispatcher)

defmodule NookalAPI do
  alias Plug.Conn
  alias Plug.Adapters.Cowboy

  import Conn

  def start(pid, port \\ 4004) do
    Cowboy.http(__MODULE__, [test_pid: pid], port: port)
  end

  def stop() do
    Process.sleep(100)
    Cowboy.shutdown(__MODULE__.HTTP)
    Process.sleep(100)
  end

  def init(opts) do
    Keyword.fetch!(opts, :test_pid)
  end

  def call(%Conn{method: "POST"} = conn, test_pid) do
    {:ok, req_body, conn} = read_body(conn)
    send(test_pid, {:request, conn.request_path, conn.req_headers, req_body})

    payload = URI.decode_query(req_body)

    case payload do
      %{"return_api_error" => _} ->
        resp_body =
          Jason.encode!(%{
            "details" => %{
              "errorCode" => "ABCD",
              "errorMessage" => "something went wrong"
            },
            "status" => "failure"
          })

        send_resp(conn, 200, resp_body)

      _ ->
        resp_body = Jason.encode!(%{"status" => "success"})
        send_resp(conn, 200, resp_body)
    end
  end

  def call(conn, _test) do
    send_resp(conn, 404, "Not Found")
  end
end
