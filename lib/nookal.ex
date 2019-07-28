defmodule Nookal do
  @client Application.get_env(:nookal, :http_client, Nookal.Client)

  @doc """
  Verify the API key.
  """
  @spec verify() :: :ok | {:error, term()}

  def verify() do
    with {:ok, _payload} <- @client.dispatch("/verify"), do: :ok
  end

  @doc """
  Get all locations.
  """
  @spec get_locations() :: {:ok, Nookal.Page.t(Nookal.Location.t())} | {:error, term()}

  def get_locations() do
    with {:ok, payload} <- @client.dispatch("/getLocations"),
         {:ok, results} <- fetch_results(payload),
         {:ok, page} <- Nookal.Page.new(payload) do
      case Map.fetch(results, "locations") do
        {:ok, raw_locations} ->
          locations =
            Enum.reduce_while(raw_locations, [], fn raw_location, acc ->
              case Nookal.Location.new(raw_location) do
                {:ok, location} ->
                  {:cont, [location | acc]}

                :error ->
                  {:halt, nil}
              end
            end)

          case locations do
            nil -> {:error, {:malformed_payload, "could not map locations from payload"}}
            locations -> {:ok, %{page | items: locations}}
          end

        :error ->
          {:error, {:malformed_payload, "could not fetch locations from payload"}}
      end
    end
  end

  defp fetch_results(payload) do
    case payload do
      %{"data" => %{"results" => results}} ->
        {:ok, results}

      _other ->
        {:error, {:malformed_payload, "could not fetch results from payload"}}
    end
  end
end
