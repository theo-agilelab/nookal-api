defmodule Nookal.Url do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          url: String.t(),
        }

  defstruct [:url]

  @mapping [
    {:url, "url", :string}
  ]

  def new(payload) do
    extract_fields(@mapping, payload, %__MODULE__{})
  end
end
