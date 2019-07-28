defmodule Nookal.Practitioner do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          speciality: String.t(),
          title: String.t(),
          email: String.t(),
          location_ids: list(String.t())
        }

  defstruct [:id, :first_name, :last_name, :speciality, :title, :email, :location_ids]

  @mapping [
    {:id, "ID"},
    {:first_name, "FirstName"},
    {:last_name, "LastName"},
    {:email, "Email"},
    {:speciality, "Speciality"},
    {:title, "Title"},
    {:location_ids, "locations"}
  ]

  def new(payload) when is_list(payload) do
    result =
      Enum.reduce_while(payload, [], fn raw_practitioner, acc ->
        case new(raw_practitioner) do
          {:ok, practitioner} ->
            {:cont, [practitioner | acc]}

          :error ->
            {:halt, nil}
        end
      end)

    if result do
      {:ok, result}
    else
      {:error, {:malformed_payload, "could not map practitioners from payload"}}
    end
  end

  def new(payload) do
    extract_fields(@mapping, payload, %__MODULE__{})
  end
end
