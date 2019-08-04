defmodule Nookal do
  @moduledoc """
  This module provides function to work with [Nookal API](https://nookal.com).

  `Nookal` uses [`mint`](https://hex.pm/packages/mint) as the HTTP client.

  Please be noted that the functions in this module are very coupled to Nookal
  API itself which can be changed at any time. Please always check Nookal API
  documentation at: [https://api.nookal.com/developers](https://api.nookal.com/developers).

  ## Configuration

  In order for `:nookal` application to work, some configurations need to be set up:

      use Mix.Config

      config :nookal, api_key: "not-2-long-but-not-2-short"

  After configuration is set, you are good to go:

      iex> Nookal.verify()
      :ok
  """

  @client Application.get_env(:nookal, :http_client, Nookal.Client)

  @doc """
  Verify if the configured API key is valid.

  ### Examples

      iex> Nookal.verify()
      :ok
  """
  @spec verify() :: :ok | {:error, term()}

  def verify() do
    with {:ok, _payload} <- @client.dispatch("/verify"), do: :ok
  end

  @doc """
  Get all locations.

  ## Example

      iex> Nookal.get_locations()
      {:ok,
       %Nookal.Page{
         current: 1,
         items: [
           %Nookal.Location{
             address: %Nookal.Address{
               city: nil,
               country: "Singapore",
               line1: "",
               line2: nil,
               line3: nil,
               postcode: "0",
               state: nil
             },
             id: "4",
             name: "Location #1",
             timezone: "Asia/Singapore"
           }
         ],
         next: nil
       }}
  """
  @spec get_locations() :: {:ok, Nookal.Page.t(Nookal.Location.t())} | {:error, term()}

  def get_locations() do
    with {:ok, payload} <- @client.dispatch("/getLocations"),
         {:ok, raw_locations} <- fetch_results(payload, "locations"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, locations} <- Nookal.Location.new(raw_locations) do
      {:ok, Nookal.Page.put_items(page, locations)}
    end
  end

  @doc """
  Get all practitioners.

  ## Example

      iex> Nookal.get_practitioners()
      {:ok,
       %Nookal.Page{
         current: 1,
         items: [
           %Nookal.Practitioner{
             email: "test@example.com",
             first_name: "Erik",
             id: "9",
             last_name: "Johanson",
             location_ids: [1],
             speciality: "Doctor",
             title: "Dr"
           },
         ],
         next: nil
       }}
  """
  @spec get_practitioners() :: {:ok, Nookal.Page.t(Nookal.Practitioner.t())} | {:error, term()}

  def get_practitioners() do
    with {:ok, payload} <- @client.dispatch("/getPractitioners"),
         {:ok, raw_practitioners} <- fetch_results(payload, "practitioners"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, practitioners} <- Nookal.Practitioner.new(raw_practitioners) do
      {:ok, Nookal.Page.put_items(page, practitioners)}
    end
  end

  @doc """
  Upload file for a patient.

  ### Examples

      file_content = File.read!("/path/to/file")
      params = %{
        "patient_id" => 1,
        "case_id" => 1,
        "name" => "Foot Scan MRI",
        "extension" => "png",
        "file_type" => "image/png",
        "file_path" => "/path/to/file"
      }

      Nookal.upload(file_content, params)
  """

  @spec upload(binary(), map()) :: {:ok, String.t()} | {:error, term()}

  def upload(file_content, params) do
    patient_id = Map.fetch!(params, "patient_id")

    with {:ok, payload} <- @client.dispatch("/uploadFile", params),
         {:ok, file_id} <- fetch_results(payload, "file_id"),
         {:ok, file_uploading_url} <- fetch_results(payload, "url"),
         :ok <- @client.upload(file_uploading_url, file_content),
         activate_params = %{"file_id" => file_id, "patient_id" => patient_id},
         {:ok, _payload} <- @client.dispatch("/setFileActive", activate_params) do
      {:ok, file_id}
    end
  end

  defp fetch_results(payload, key) do
    case payload do
      %{"data" => %{"results" => %{^key => data}}} ->
        {:ok, data}

      _other ->
        {:error, {:malformed_payload, "could not fetch #{inspect(key)} from payload"}}
    end
  end
end
