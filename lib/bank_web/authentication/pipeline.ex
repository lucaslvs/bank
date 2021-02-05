defmodule BankWeb.Authentication.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :bank,
    module: BankWeb.Authentication.Guardian,
    error_handler: BankWeb.Authentication.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
