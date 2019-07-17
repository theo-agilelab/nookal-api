defmodule Nookal.Address do
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
end
