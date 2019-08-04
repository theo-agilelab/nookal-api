defmodule Nookal.ClientTest do
  use ExUnit.Case

  setup do
    NookalAPI.start(self())
    on_exit(&NookalAPI.stop/0)
    :ok
  end

  @moduletag :integration

  describe "dispatch/2" do
    test "dispatches requests to remote server" do
      api_uri = URI.parse("http://localhost:4004")
      start_supervised!({Nookal.Connection, api_uri}, id: Nookal.Connection)

      Nookal.Client.dispatch("/foo")

      assert_received {:request, req_path, req_headers, req_body}

      assert req_path == "/production/v2/foo"

      assert get_header(req_headers, "content-type") ==
               "application/x-www-form-urlencoded; charset=UTF-8"

      assert get_header(req_headers, "accept") == "application/json"

      assert req_body == "api_key=dummy"
    end

    test "handles errors from the requests" do
      api_uri = URI.parse("http://localhost:4004")
      start_supervised!({Nookal.Connection, api_uri}, id: Nookal.Connection)

      assert Nookal.Client.dispatch("/foo", %{"return_api_error" => "1"}) ==
               {:error, {:api_failure, "something went wrong"}}

      assert_received {:request, req_path, req_headers, req_body}

      assert req_path == "/production/v2/foo"

      assert get_header(req_headers, "content-type") ==
               "application/x-www-form-urlencoded; charset=UTF-8"

      assert get_header(req_headers, "accept") == "application/json"

      assert req_body == "api_key=dummy&return_api_error=1"
    end
  end

  describe "upload/2" do
    test "uploads file to remote server" do
      start_supervised!({Nookal.Uploader, []}, id: Nookal.Uploader)

      file_content = <<1, 2, 3>>
      assert Nookal.Client.upload("http://localhost:4004/test_upload?foo=bar", file_content)

      assert_received {:upload, ^file_content}
    end
  end

  defp get_header(headers, name) do
    List.first(for {^name, value} <- headers, do: value)
  end
end
