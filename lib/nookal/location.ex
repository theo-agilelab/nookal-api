defmodule Nookal.Location do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          timezone: String.t()
        }

  defstruct [:id, :name, :address, :timezone]

  @mapping [
    {:id, "ID"},
    {:name, "Name"},
    {:timezone, "Timezone"}
  ]

  def new(payload) when is_list(payload) do
    locations =
      Enum.reduce_while(payload, [], fn raw_location, acc ->
        case Nookal.Location.new(raw_location) do
          {:ok, location} ->
            {:cont, [location | acc]}

          :error ->
            {:halt, nil}
        end
      end)

    case locations do
      nil -> {:error, {:malformed_payload, "could not map locations from payload"}}
      locations -> {:ok, locations}
    end
  end

  def new(payload) do
    case extract_fields(@mapping, payload, %__MODULE__{}) do
      {:ok, location} ->
        location =
          case Nookal.Address.new(payload) do
            {:ok, address} ->
              %{location | address: address}

            :error ->
              location
          end

        {:ok, location}

      :error ->
        :error
    end
  end
end
