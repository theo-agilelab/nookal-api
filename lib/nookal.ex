defmodule Nookal do
  @client Application.get_env(:nookal, :http_client, Nookal.Client)

  @doc """
  Verify the API key.
  """
  @spec verify() :: :ok | {:error, term()}
  def verify() do
    with {:ok, _payload} <- @client.dispatch("/verify"), do: :ok
  end
end
