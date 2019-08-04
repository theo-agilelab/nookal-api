defmodule Nookal.Uploader do
  @moduledoc false

  def child_spec([]) do
    %{
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def start_link() do
    children = [
      :poolboy.child_spec(
        :uploader_pool,
        [
          {:name, {:local, :uploader_pool}},
          {:worker_module, Nookal.Uploader.Connection},
          {:size, 3},
          {:max_overflow, 1}
        ]
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Nookal.Uploader)
  end

  def upload(uploading_url, file_content) do
    :poolboy.transaction(
      :uploader_pool,
      &Nookal.Uploader.Connection.upload(&1, uploading_url, file_content),
      _checkout_timeout = 500
    )
  end
end
