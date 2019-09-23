defmodule Nookal.Document do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: String.t(),
          mime: String.t(),
          name: String.t(),
          extension: String.t(),
          patient_id: integer(),
          case_id: integer(),
          status: Boolean.t(),
          metadata: String.t()
        }

  defstruct [
    :id,
    :mime,
    :name,
    :extension,
    :patient_id,
    :case_id,
    :status,
    :metadata
  ]

  @mapping [
    {:id, "ID", :string},
    {:mime, "mime", :string},
    {:name, "name", :string},
    {:extension, "extension", :string},
    {:patient_id, "patientID", :integer},
    {:case_id, "caseID", :integer},
    {:status, "status", :boolean},
    {:metadata, "metadata", :string}
  ]

  def new(payload) when is_list(payload) do
    all_or_none_map(payload, &new/1)
  end

  def new(payload) do
    with {:ok, document} <- extract_fields(@mapping, payload, %__MODULE__{}) do
      {:ok, document}
    end
  end

  # def new_url(document) do
  #   Nookal.get_file_url(%{"patient_id" => document["patientID"], "file_id" => document["ID"]})
  # end
end
