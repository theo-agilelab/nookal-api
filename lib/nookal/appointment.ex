defmodule Nookal.Appointment do
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
    :did_not_arrive?,
    :cancelled?,
    :invoice_generated?,
    :cancellation_date,
    :notes,
    :date_created,
    :date_modified
  ]
end
