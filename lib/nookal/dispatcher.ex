defmodule Nookal.Dispatcher do
  @moduledoc false

  @callback dispatch(req_path :: String.t()) :: {:ok, term()} | {:error, term()}
  @callback dispatch(req_path :: String.t(), req_params :: map()) ::
              {:ok, term()} | {:error, term()}
  @callback upload(file_content :: String.t(), req_params :: map()) ::
              {:ok, term()} | {:error, term()}
end
