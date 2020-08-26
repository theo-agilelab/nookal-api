defmodule Nookal.Document do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: String.t(),
          mime: String.t(),
          name: String.t(),
          extension: String.t(),
          patient_id: integer(),
          case_id: integer(),
          metadata: String.t(),
          status: String.t()
        }

  defstruct [
    :id,
    :mime,
    :name,
    :extension,
    :patient_id,
    :case_id,
    :metadata,
    :status
  ]

  @mapping [
    {:id, "ID", :string},
    {:mime, "mime", :string},
    {:name, "name", :string},
    {:extension, "extension", :string},
    {:patient_id, "patientID", :integer},
    {:case_id, "caseID", :integer},
    {:metadata, "metadata", :string},
    {:status, "status", :string}
  ]

  def new(payload) when is_list(payload) do
    all_or_none_map(payload, &new/1)
  end

  def new(payload) do
    with {:ok, document} <- extract_fields(@mapping, payload, %__MODULE__{}) do
      {:ok, document}
    end
  end

  def fetch_valid_data(documents) do
    Enum.filter(documents, &match?(%Nookal.Document{:status => x} when x != "0", &1))
  end
end
