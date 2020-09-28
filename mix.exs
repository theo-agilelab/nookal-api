defmodule Nookal.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project() do
    [
      app: :nookal,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
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
      {:mint, "~> 1.1"},
      {:connection, "~> 1.0.4"},
      {:jason, "~> 1.1"},
      {:poolboy, "~> 1.5"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:mox, "~> 0.5.0", only: :test},
      {:plug_cowboy, "~> 2.1", only: :test}
    ]
  end

  defp docs() do
    [
      main: "Nookal",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/nookal",
      source_url: "https://github.com/agilelabsg/nookal",
      groups_for_modules: [
        API: [
          Nookal
        ],
        Structs: [
          Nookal.Address,
          Nookal.Appointment,
          Nookal.Availability,
          Nookal.Case,
          Nookal.Class,
          Nookal.Contact,
          Nookal.Invoice,
          Nookal.Location,
          Nookal.Page,
          Nookal.Patient,
          Nookal.Practitioner,
          Nookal.Service,
          Nookal.TreatmentNote,
          Nookal.Document,
          Nookal.Url
        ]
      ]
    ]
  end
end
