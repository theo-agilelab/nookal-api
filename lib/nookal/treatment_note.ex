defmodule Nookal.TreatmentNote do
  import Nookal.Utils

  @type t() :: %__MODULE__{
    id: integer(),
    patient_id: integer(),
    practitioner_id: integer(),
    case_id: integer(),
    answers: Original.t(),
    template: Original.t()
  }

  defstruct [:id, :patient_id, :practitioner_id, :case_id, :html, :answers, :template]

  @mapping [
    {:id, "noteID", :integer},
    {:patient_id, "clientID", :integer},
    {:practitioner_id, "practitionerID", :integer},
    {:case_id, "caseID", :integer},
    {:answers, "answers", :original},
    {:template, "template", :original}
  ]

  def new(payload) when is_list(payload) do
    all_or_none_map(payload, &new/1)
  end

  def new(payload) do
    with {:ok, treatment_notes} <- extract_fields(@mapping, payload, %__MODULE__{}) do
      {:ok, treatment_notes}
    end
  end
end
