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
         {:ok, raw_locations} <- fetch_results(payload, "locations"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, locations} <- Nookal.Location.new(raw_locations) do
      {:ok, Nookal.Page.put_items(page, locations)}
    end
  end

  @doc """
  Get practitioners.
  """
  @spec get_practitioners() :: {:ok, Nookal.Page.t(Nookal.Practitioner.t())} | {:error, term()}

  def get_practitioners() do
    with {:ok, payload} <- @client.dispatch("/getPractitioners"),
         {:ok, raw_practitioners} <- fetch_results(payload, "practitioners"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, practitioners} <- Nookal.Practitioner.new(raw_practitioners) do
      {:ok, Nookal.Page.put_items(page, practitioners)}
    end
  end

  defp fetch_results(payload, key) do
    case payload do
      %{"data" => %{"results" => %{^key => data}}} ->
        {:ok, data}

      _other ->
        {:error, {:malformed_payload, "could not fetch #{inspect(key)} from payload"}}
    end
  end
end
