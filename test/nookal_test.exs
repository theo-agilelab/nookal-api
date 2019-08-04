defmodule NookalTest do
  use ExUnit.Case, async: true

  import Mox

  alias Nookal.ClientMock

  setup :verify_on_exit!

  describe "verify/0" do
    test "verifies the token validity" do
      expect_dispatch(fn req_path ->
        assert req_path == "/verify"
        {:ok, Jason.encode!(%{})}
      end)

      assert Nookal.verify() == :ok
    end

    test "returns invalid token error message" do
      expect_dispatch(fn req_path ->
        assert req_path == "/verify"
        {:error, {:api_failure, "something went wrong"}}
      end)

      assert Nookal.verify() == {:error, {:api_failure, "something went wrong"}}
    end
  end

  describe "get_locations/0" do
    test "retrieves locations" do
      resp_payload = read_api_fixture("get_locations")

      expect_dispatch(fn req_path ->
        assert req_path == "/getLocations"

        {:ok, resp_payload}
      end)

      assert {:ok, page} = Nookal.get_locations()

      assert page.items == [
               %Nookal.Location{
                 address: %Nookal.Address{
                   city: "New York",
                   country: "USA",
                   line1: "42 Foo Street",
                   line2: "Azusa New York",
                   line3: nil,
                   postcode: "123456",
                   state: nil
                 },
                 id: "1",
                 name: "Foo",
                 timezone: "UTC"
               }
             ]

      assert page.current == 1
      assert page.next == nil
    end

    test "handles malformed payload" do
      complete_payload = read_api_fixture("get_locations")

      {_, resp_payload} = pop_in(complete_payload, ["data", "results"])
      expect_dispatch(fn _ -> {:ok, resp_payload} end)

      assert Nookal.get_locations() ==
               {:error, {:malformed_payload, "could not fetch \"locations\" from payload"}}

      {_, resp_payload} = pop_in(complete_payload, ["data", "results", "locations"])
      expect_dispatch(fn _ -> {:ok, resp_payload} end)

      assert Nookal.get_locations() ==
               {:error, {:malformed_payload, "could not fetch \"locations\" from payload"}}

      resp_payload =
        update_in(complete_payload, ["data", "results", "locations", Access.at(0)], fn item ->
          Map.delete(item, "ID")
        end)

      expect_dispatch(fn _ -> {:ok, resp_payload} end)

      assert Nookal.get_locations() ==
               {:error, {:malformed_payload, "could not map locations from payload"}}

      {_, resp_payload} =
        pop_in(complete_payload, ["data", "results", "locations", Access.at(0), "AddressLine1"])

      expect_dispatch(fn _ -> {:ok, resp_payload} end)

      assert {:ok, %Nookal.Page{items: [location]}} = Nookal.get_locations()
      assert location.address == nil
    end
  end

  describe "get_practitioners/0" do
    test "retrieves practitioner from remote server" do
      resp_payload = read_api_fixture("get_practitioners")

      expect_dispatch(fn req_path ->
        assert req_path == "/getPractitioners"

        {:ok, resp_payload}
      end)

      assert {:ok, page} = Nookal.get_practitioners()

      assert page.items == [
               %Nookal.Practitioner{
                 email: "john.doe@example.com",
                 first_name: "John",
                 id: "1",
                 last_name: "Doe",
                 location_ids: [1],
                 speciality: "Doctor",
                 title: "Dr"
               }
             ]

      assert page.current == 1
      assert page.next == nil
    end
  end

  describe "upload/2" do
    test "uploads file to remote server" do
      file_content = "foo.bar"

      params = %{
        "patient_id" => 1,
        "case_id" => 1,
        "name" => "Test Sample #1",
        "extension" => "png",
        "file_type" => "image/png",
        "file_path" => "/path/to/file"
      }

      expect_dispatch(fn req_path, req_params ->
        assert req_path == "/uploadFile"
        assert req_params == params

        {:ok, read_api_fixture("upload_file")}
      end)

      expect(ClientMock, :upload, fn url, content ->
        assert url == "http://cloud.example.com/path/to/file?foo=bar"
        assert content == file_content

        :ok
      end)

      expect_dispatch(fn req_path, req_params ->
        assert req_path == "/setFileActive"
        assert req_params == %{"file_id" => "file_123", "patient_id" => 1}

        {:ok, read_api_fixture("activate_file")}
      end)

      assert {:ok, file_id} = Nookal.upload(file_content, params)
      assert file_id == "file_123"
    end

    test "handles cloud uploading failure" do
      file_content = "foo.bar"

      params = %{
        "patient_id" => 1,
        "case_id" => 1,
        "name" => "Test Sample #1",
        "extension" => "png",
        "file_type" => "image/png",
        "file_path" => "/path/to/file"
      }

      expect_dispatch(fn req_path, req_params ->
        assert req_path == "/uploadFile"
        assert req_params == params

        {:ok, read_api_fixture("upload_file")}
      end)

      expect(ClientMock, :upload, fn url, content ->
        assert url == "http://cloud.example.com/path/to/file?foo=bar"
        assert content == file_content

        {:error, {:upload_failure, :random_failure}}
      end)

      assert Nookal.upload(file_content, params) == {:error, {:upload_failure, :random_failure}}
    end

    test "handles activation failure" do
      file_content = "foo.bar"

      params = %{"patient_id" => 1}

      expect_dispatch(fn req_path, _req_params ->
        assert req_path == "/uploadFile"

        {:ok, read_api_fixture("upload_file")}
      end)

      expect(ClientMock, :upload, fn _, _ -> :ok end)

      expect_dispatch(fn req_path, _req_params ->
        assert req_path == "/setFileActive"

        {:error, {:request_failure, :random_failure}}
      end)

      assert Nookal.upload(file_content, params) == {:error, {:request_failure, :random_failure}}
    end
  end

  defp expect_dispatch(fun) do
    expect(ClientMock, :dispatch, fun)
  end

  defp read_api_fixture(file_name) do
    file_path = "./test/fixtures/api/" <> file_name <> ".json"

    file_path
    |> Path.expand()
    |> File.read!()
    |> Jason.decode!()
  end
end
