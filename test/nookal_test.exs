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

  describe "get_locations/1" do
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
               {:error, {:malformed_payload, "could not fetch results from payload"}}

      {_, resp_payload} = pop_in(complete_payload, ["data", "results", "locations"])
      expect_dispatch(fn _ -> {:ok, resp_payload} end)

      assert Nookal.get_locations() ==
               {:error, {:malformed_payload, "could not fetch locations from payload"}}

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
