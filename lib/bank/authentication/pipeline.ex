defmodule Bank.Authentication.Pipeline do
  use Guardian.Plug.Pipeline,
    opt_app: :bank,
    module: Bank.Authentication.Guardian,
    error_handler: Bank.Authentication.ErrorHandler

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"type" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
