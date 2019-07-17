defmodule Nookal.Invoice do
  defstruct [
    :id,
    :number,
    :patient_id,
    :practitioner_id,
    :date_created,
    :location_id,
    :third_party_invoice?,
    :invoice_notes,
    :account_notes,
    :other_notes,
    :account,
    :contact
  ]
end
