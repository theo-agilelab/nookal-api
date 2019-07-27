defmodule NookalTest do
  use ExUnit.Case, async: true

  import Mox

  alias Nookal.ClientMock

  setup :verify_on_exit!

  describe "verify/0" do
    test "verifies the token validity" do
      expect(ClientMock, :dispatch, fn req_path ->
        assert req_path == "/verify"
        {:ok, Jason.encode!(%{})}
      end)

      assert Nookal.verify() == :ok
    end

    test "returns invalid token error message" do
      expect(ClientMock, :dispatch, fn req_path ->
        assert req_path == "/verify"
        {:error, {:api_failure, "something went wrong"}}
      end)

      assert Nookal.verify() == {:error, {:api_failure, "something went wrong"}}
    end
  end
end
