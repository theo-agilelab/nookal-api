defmodule Nookal.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project() do
    [
      app: :nookal,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [
        exclude: [
          Nookal.ClientMock
        ]
      ]
    ]
  end

  def application() do
    [
      extra_applications: [:logger],
      mod: {Nookal.Application, []}
    ]
  end

  defp deps() do
    [
      {:castore, "~> 0.1.0"},
      {:mint, "~> 0.4.0"},
      {:connection, "~> 1.0.4"},
      {:jason, "~> 1.1"},
      {:poolboy, "~> 1.5"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:mox, "~> 0.5.0", only: :test},
      {:plug_cowboy, "~> 2.1", only: :test}
    ]
  end
end
