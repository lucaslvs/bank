defmodule BankWeb.Authentication.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bank,
    module: BankWeb.Authentication.Guardian,
    error_handler: BankWeb.Authentication.ErrorHandler

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"type" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
