defmodule Nookal.Dispatcher do
  @callback dispatch(req_path :: String.t()) :: {:ok, term()} | {:error, term()}
  @callback dispatch(req_path :: String.t(), req_params :: map()) ::
              {:ok, term()} | {:error, term()}
end
