defmodule Nookal.Utils do
  @moduledoc false

  def extract_fields([{field, key} | rest], payload, acc) do
    with {:ok, value} <- Map.fetch(payload, key) do
      extract_fields(rest, payload, %{acc | field => value})
    end
  end

  def extract_fields([], _payload, acc) do
    {:ok, acc}
  end
end
