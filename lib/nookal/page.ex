defmodule Nookal.Page do
  @type t(struct) :: %__MODULE__{
          items: list(struct),
          current: integer(),
          next: integer()
        }

  defstruct [:current, :next, items: []]

  def new(%{"settings" => settings}) do
    {:ok,
     %__MODULE__{
       current: maybe_parse_integer(settings["currentPage"]),
       next: maybe_parse_integer(settings["nextPage"])
     }}
  end

  def new(_payload) do
    {:error, {:malformed_payload, "could not build page from payload"}}
  end

  def put_items(%__MODULE__{} = page, items) when is_list(items) do
    %{page | items: items}
  end

  defp maybe_parse_integer(value) do
    case Nookal.Utils.cast(value, :integer) do
      {:ok, integer} -> integer
      {:error, _reason} -> nil
    end
  end
end
