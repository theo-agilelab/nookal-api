defmodule Nookal.Patient do
  import Nookal.Utils

  @type t() :: %__MODULE__{
          id: integer(),
          title: String.t(),
          first_name: String.t(),
          middle_name: String.t(),
          last_name: String.t(),
          nickname: String.t(),
          name: String.t(),
          dob: Date.t(),
          gender: String.t(),
          notes: String.t(),
          alerts: String.t(),
          occupation: String.t(),
          employer: String.t(),
          category: String.t(),
          location_id: integer(),
          email: String.t(),
          mobile: String.t(),
          address: Nookal.Address.t(),
          postal_address: Nookal.Address.t(),
          online_code: String.t(),
          date_created: NaiveDateTime.t(),
          date_modified: NaiveDateTime.t()
        }

  defstruct [
    :id,
    :title,
    :first_name,
    :middle_name,
    :last_name,
    :nickname,
    :name,
    :dob,
    :gender,
    :notes,
    :alerts,
    :occupation,
    :employer,
    :category,
    :location_id,
    :email,
    :mobile,
    :address,
    :postal_address,
    :online_code,
    :date_created,
    :date_modified
  ]

  @mapping [
    {:id, "ID", :integer},
    {:title, "Title", :string},
    {:first_name, "FirstName", :string},
    {:middle_name, "MiddleName", :string},
    {:last_name, "LastName", :string},
    {:nickname, "Nickname", :string},
    {:dob, "DOB", :date},
    {:gender, "Gender", :string},
    {:notes, "Notes", :string},
    {:alerts, "Alerts", :string},
    {:occupation, "Occupation", :string},
    {:employer, "Employer", :string},
    {:category, "category", :string},
    {:location_id, "LocationID", :integer},
    {:email, "Email", :string},
    {:mobile, "Mobile", :string},
    {:online_code, "onlineQuickCode", :string},
    {:date_created, "DateCreated", :naive_date_time},
    {:date_modified, "DateModified", :naive_date_time}
  ]

  def new(payload) when is_list(payload) do
    all_or_none_map(payload, &new/1)
  end

  def new(payload) do
    with {:ok, patient} <- extract_fields(@mapping, payload, %__MODULE__{}) do
      patient =
        patient
        |> Map.replace!(:address, new_address(payload))
        |> Map.replace!(:postal_address, new_postal_address(payload))
        |> Map.replace!(:name, generate_name(payload))

      {:ok, patient}
    end
  end

  defp replace_map_key(map, old_key, new_key) do
    {value, map} = Map.pop(map, old_key)

    Map.put(map, new_key, value)
  end

  defp new_address(payload) do
    case payload
         |> Map.take(["Addr1", "Addr2", "Addr3", "City", "State", "Country", "Postcode"])
         |> replace_map_key("Addr1", "AddressLine1")
         |> replace_map_key("Addr2", "AddressLine2")
         |> replace_map_key("Addr3", "AddressLine3")
         |> Nookal.Address.new() do
      {:ok, address} -> address
      {:error, _reason} -> nil
    end
  end

  defp new_postal_address(payload) do
    keys = [
      "Postal_Addr1",
      "Postal_Addr2",
      "Postal_Addr3",
      "Postal_City",
      "Postal_State",
      "Postal_Country",
      "Postal_Postcode"
    ]

    case payload
         |> Map.take(keys)
         |> replace_map_key("Postal_Addr1", "AddressLine1")
         |> replace_map_key("Postal_Addr2", "AddressLine2")
         |> replace_map_key("Postal_Addr3", "AddressLine3")
         |> replace_map_key("Postal_City", "City")
         |> replace_map_key("Postal_State", "State")
         |> replace_map_key("Postal_Country", "Country")
         |> replace_map_key("Postal_Postcode", "Postcode")
         |> Nookal.Address.new() do
      {:ok, address} -> address
      {:error, _reason} -> nil
    end
  end

  defp generate_name(payload) do
    payload["FirstName"] <> " " <> payload["LastName"]
  end
end
