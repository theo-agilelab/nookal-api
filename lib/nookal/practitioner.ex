defmodule Nookal.Practitioner do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: integer(),
          first_name: String.t(),
          last_name: String.t(),
          speciality: String.t(),
          title: String.t(),
          email: String.t(),
          location_ids: list(integer())
        }

  defstruct [:id, :first_name, :last_name, :speciality, :title, :email, :location_ids]

  @mapping [
    {:id, "ID", :integer},
    {:first_name, "FirstName", :string},
    {:last_name, "LastName", :string},
    {:email, "Email", :string},
    {:speciality, "Speciality", :string},
    {:title, "Title", :string},
    {:location_ids, "locations", {:list, :integer}}
  ]

  def new(payload) when is_list(payload) do
    with {:error, reason} <- all_or_none_map(payload, &new/1) do
      {:error, {:malformed_payload, "could not map practitioners from payload" <> reason}}
    end
  end

  def new(payload) do
    extract_fields(@mapping, payload, %__MODULE__{})
  end
end
