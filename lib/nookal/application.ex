defmodule Nookal.Application do
  @moduledoc false

  use Application

  def start(_, _) do
    api_endpoint_uri =
      :nookal
      |> Application.get_env(:api_endpoint, "https://api.nookal.com")
      |> URI.parse()

    children = [
      {Nookal.Client, api_endpoint_uri}
    ]

    options = [strategy: :one_for_one, name: Nookal.Supervisor]
    Supervisor.start_link(children, options)
  end
end
