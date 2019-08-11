defmodule Nookal.Utils do
  @moduledoc false

  def extract_fields([{field, key, type} | rest], payload, acc) do
    case Map.fetch(payload, key) do
      {:ok, value} ->
        with {:ok, cast_value} <- cast(value, type) do
          extract_fields(rest, payload, %{acc | field => cast_value})
        end

      :error ->
        {:error, "could not fetch #{inspect(key)} in payload"}
    end
  end

  def extract_fields([], _payload, acc) do
    {:ok, acc}
  end

  def cast(nil, _type), do: {:ok, nil}

  def cast(values, {:list, type}) when is_list(values) do
    with {:error, _reason} <- all_or_none_map(values, &cast(&1, type)) do
      cast_error(values, {:list, type})
    end
  end

  def cast(value, :string) when is_binary(value) do
    {:ok, value}
  end

  def cast(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> {:ok, integer}
      _other -> cast_error(value, :integer)
    end
  end

  def cast(value, :integer) when is_integer(value) do
    {:ok, value}
  end

  def cast(value, :date) when is_binary(value) do
    with {:error, _reason} <- Date.from_iso8601(value) do
      cast_error(value, :date)
    end
  end

  def cast(value, :naive_date_time) when is_binary(value) do
    with [date, time] <- String.split(value, " "),
         {:ok, date} <- Date.from_iso8601(date),
         {:ok, time} <- Time.from_iso8601(time),
         {:ok, naive_datetime} <- NaiveDateTime.new(date, time) do
      {:ok, naive_datetime}
    else
      _ -> {:ok, nil}
    end
  end

  def cast(value, type), do: cast_error(value, type)

  @compile {:inline, [cast_error: 2]}
  defp cast_error(value, type) do
    {:error, "could not cast #{inspect(value)} to #{inspect(type)}"}
  end

  def all_or_none_map(enumerables, fun) do
    result =
      Enum.reduce_while(enumerables, [], fn element, mapped ->
        case fun.(element) do
          {:ok, element} -> {:cont, [element | mapped]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case result do
      {:error, reason} -> {:error, reason}
      mapped -> {:ok, Enum.reverse(mapped)}
    end
  end
end
