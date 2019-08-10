defmodule Nookal.Address do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          line1: String.t(),
          line2: String.t(),
          line3: String.t(),
          city: String.t(),
          state: String.t(),
          country: String.t(),
          postcode: String.t()
        }

  defstruct [:line1, :line2, :line3, :city, :state, :country, :postcode]

  @mapping [
    {:line1, "AddressLine1", :string},
    {:line2, "AddressLine2", :string},
    {:line3, "AddressLine3", :string},
    {:city, "City", :string},
    {:state, "State", :string},
    {:country, "Country", :string},
    {:postcode, "Postcode", :string}
  ]

  def new(payload) do
    extract_fields(@mapping, payload, %__MODULE__{})
  end
end
