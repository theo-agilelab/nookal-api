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
  Get patients in a page.

  Please check [API specs](https://api.nookal.com/dev/reference/patient) for more information.

  ## Examples

      iex> Nookal.get_patients(%{"page_length" => 1})
      {:ok,
       %Nookal.Page{
         current: 1,
         items: [
           %Nookal.Patient{
             address: %Nookal.Address{
               city: "Berlin Wedding",
               country: "Germany",
               line1: "Genslerstraße 84",
               line2: "",
               line3: "",
               postcode: "13339",
               state: "Berlin"
             },
             alerts: "",
             category: "",
             date_created: nil,
             date_modified: nil,
             dob: ~D[1989-01-01],
             email: "patrick@example.com",
             employer: "Berlin Solutions",
             first_name: "Patrick",
             gender: "F",
             id: 1,
             last_name: "Propst",
             location_id: 1,
             middle_name: "Kahn",
             mobile: "98989899",
             nickname: "",
             notes: "",
             occupation: "",
             online_code: "ABC123",
             postal_address: %Nookal.Address{
               city: "Berlin Wedding",
               country: "Germany",
               line1: "Genslerstraße 84",
               line2: "",
               line3: "",
               postcode: "13339",
               state: "Berlin"
             },
             title: "Mr"
           }
         ],
         next: 2
       }}

  """

  @spec get_patients(map()) :: {:ok, Nookal.Page.t(Nookal.Patient.t())} | {:error, term()}

  def get_patients(params \\ %{}) do
    with {:ok, payload} <- @client.dispatch("/getPatients", params),
         {:ok, raw_patients} <- fetch_results(payload, "patients"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, patients} <- Nookal.Patient.new(raw_patients) do
      {:ok, Nookal.Page.put_items(page, patients)}
    end
  end

  @doc """
  Get appointments in a page.

  Please check [API specs](https://api.nookal.com/dev/objects/appointment) for more information.

  ## Examples

    iex> Nookal.get_appointments(%{"page_length" => 1})
    %Nookal.Page{
      current: 1,
      items: [
        %Nookal.Appointment{
          arrived?: 0,
          cancellation_date: nil,
          cancelled?: 0,
          date: ~D[2019-09-05],
          date_created: ~N[2019-09-03 05:47:48],
          date_modified: ~N[2019-09-04 09:28:33],
          email_reminder_sent?: 0,
          end_time: nil,
          id: 1,
          invoice_generated?: 0,
          location_id: 1,
          notes: nil,
          patient_id: 1,
          practitioner_id: 1,
          start_time: nil,
          type: "Consultation",
          type_id: 1
        }
      ],
      next: 2
    }
      
  """

  @spec get_appointments(map()) :: {:ok, Nookal.Page.t(Nookal.Appointment.t())} | {:error, term()}

  def get_appointments(params \\ %{}) do
    with {:ok, payload} <- @client.dispatch("/getAppointments", params),
         {:ok, raw_appointments} <- fetch_results(payload, "appointments"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, appointments} <- Nookal.Appointment.new(raw_appointments) do
      {:ok, Nookal.Page.put_items(page, appointments)}
    end
  end

  @doc """

  Get documents in a page.

  Please check [API specs](https://api.nookal.com/dev/objects/files) for more information.

  ## Examples

    iex> Nookal.get_documents(%{"patient_id" => 1, "page" => 1, "page_length" => 1})
    %Nookal.Page{
      current: 1,
      items: [
        %Nookal.Document{
          case_id: nil,
          extension: "jpg",
          id: "file_5d6e2ab9187b08.77130737",
          metadata: nil,
          mime: "image/jpeg",
          name: "profile_image",
          patient_id: 1,
          status: true,
          url: "https://example.com/image.png"
        }
      ],
      next: 2
    }
  """

  @spec get_documents(map()) :: {:ok, Nookal.Page.t(Nookal.Document.t())} | {:error, term()}

  def get_documents(params \\ %{}) do
    with {:ok, payload} <- @client.dispatch("/getPatientFiles", params),
         {:ok, raw_documents} <- fetch_results(payload, "files"),
         {:ok, page} <- Nookal.Page.new(payload),
         {:ok, documents} <- Nookal.Document.new(raw_documents) do
      {:ok, Nookal.Page.put_items(page, documents)}
    end
  end

  @doc """
  Get file URL.

  Please check [API specs](https://api.nookal.com/dev/objects/files) for more information.

  ## Examples

      iex> Nookal.get_file_url(%{"patient_id" => 1, "file_id" => "file_5d6e2ab9187b08.77130737"})
      "https:example.com/image.png"
  """

  @spec get_file_url(map()) :: {:ok, String.t()} | {:error, term()}

  def get_file_url(params \\ %{}) do
    with {:ok, payload} <- @client.dispatch("/getFileUrl", params),
         {:ok, raw_url} <- fetch_results(payload, "url") do
      raw_url
    end
  end

  @doc """
    Get Treatment Notes.

    Please check [API specs](https://api.nookal.com/dev/objects/treatment) for more information.

    ## Examples

    iex> 
  """

  spec get_treatment_notes(map()) :: {:ok, Nookal.Page.t(Nookal.TreatmentNote.t())} | {:error, term()}

  def get_treatment_notes(params \\ %{}) do
    with {:ok, payload} <- @client.dispatch("getTreatmentNotes") do
      IO.inspect(payload)
    end
  end

  @doc """
  Stream pages with the request function.

  ## Examples

      iex> request_fun = fn current_page ->
      ...>   Nookal.get_patients(%{
      ...>     "page" => current_page,
      ...>     "page_length" => 15
      ...>   })
      ...> end
      ...>
      ...> request_fun
      ...> |> Nookal.stream_pages()
      ...> |> Stream.flat_map(fn page -> page.items end)
      ...> |> Enum.to_list()
      [
        %Nookal.Patient{
          id: 1,
          first_name: "Patrick",
          last_name: "Propst",
          ...
        },
        %Nookal.Patient{
          id: 2,
          first_name: "Johan",
          last_name: "Kesling",
          ...
        }
      ]
  """

  @spec stream_pages((integer() -> {:ok, Nookal.Page.t(any())} | {:error, term()}), integer()) ::
          Enumerable.t()

  def stream_pages(request_fun, starting_page \\ 1) do
    Stream.unfold(starting_page, fn current_page ->
      if current_page do
        case request_fun.(current_page) do
          {:ok, %Nookal.Page{} = page} ->
            {page, page.next}

          {:error, _reason} ->
            nil
        end
      end
    end)
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
