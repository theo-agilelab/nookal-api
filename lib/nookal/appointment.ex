defmodule Nookal.Appointment do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: integer(),
          patient_id: integer(),
          date: Date.t(),
          start_time: Time.t(),
          end_time: Time.t(),
          location_id: integer(),
          type: String.t(),
          type_id: integer(),
          practitioner_id: integer(),
          email_reminder_sent?: Boolean.t(),
          arrived?: Boolean.t(),
          cancelled?: Boolean.t(),
          invoice_generated?: Boolean.t(),
          cancellation_date: NaiveDateTime.t(),
          notes: String.t(),
          date_created: NaiveDateTime.t(),
          date_modified: NaiveDateTime.t()
        }

  defstruct [
    :id,
    :patient_id,
    :date,
    :start_time,
    :end_time,
    :location_id,
    :type,
    :type_id,
    :practitioner_id,
    :email_reminder_sent?,
    :arrived?,
    :cancelled?,
    :invoice_generated?,
    :cancellation_date,
    :notes,
    :date_created,
    :date_modified
  ]

  @mapping [
    {:id, "ID", :integer},
    {:patient_id, "patientID", :integer},
    {:date, "appointmentDate", :date},
    {:start_time, "appointmentStartTime", :time},
    {:end_time, "appointmentEndTime", :time},
    {:location_id, "locationID", :integer},
    {:type, "appointmentType", :string},
    {:type_id, "appointmentTypeID", :integer},
    {:practitioner_id, "practitionerID", :integer},
    {:email_reminder_sent?, "emailReminderSent", :boolean},
    {:arrived?, "arrived", :boolean},
    {:cancelled?, "cancelled", :boolean},
    {:invoice_generated?, "invoiceGenerated", :boolean},
    {:cancellation_date, "cancellationDate", :naive_date_time},
    {:notes, "Notes", :string},
    {:date_created, "dateCreated", :naive_date_time},
    {:date_modified, "lastModified", :naive_date_time}
  ]

  def new(payload) when is_list(payload) do
    all_or_none_map(payload, &new/1)
  end

  def new(payload) do
    IO.inspect(payload)
    with {:ok, appointment} <- extract_fields(@mapping, payload, %__MODULE__{}) do
      {:ok, appointment}
    end
  end
end
