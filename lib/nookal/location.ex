defmodule Nookal.Location do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: integer(),
          name: String.t(),
          timezone: String.t()
        }

  defstruct [:id, :name, :address, :timezone]

  @mapping [
    {:id, "ID", :integer},
    {:name, "Name", :string},
    {:timezone, "Timezone", :string}
  ]

  def new(payload) when is_list(payload) do
    with {:error, reason} <- all_or_none_map(payload, &new/1) do
      {:error, {:malformed_payload, "could not map locations from payload, reason: " <> reason}}
    end
  end

  def new(payload) do
    with {:ok, location} <- extract_fields(@mapping, payload, %__MODULE__{}) do
      location =
        case Nookal.Address.new(payload) do
          {:ok, address} ->
            %{location | address: address}

          {:error, _reason} ->
            location
        end

      {:ok, location}
    end
  end
end
