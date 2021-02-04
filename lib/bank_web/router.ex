defmodule BankWeb.Router do
  @moduledoc false

  use BankWeb, :router

  pipeline :api do
    plug CORSPlug, origin: ["*"]
    plug :accepts, ["json"]
    plug Casex.CamelCaseDecoderPlug
  end

  pipeline :auth do
    plug BankWeb.Authentication.Pipeline
  end

  scope "/api", BankWeb, as: :api do
    scope "/v1", V1, as: :v1 do
      pipe_through :api

      # coveralls-ignore-start
      options "/accounts", AccountController, :options
      options "/tokens", TokenController, :options

      # coveralls-ignore-stop

      resources "/accounts", AccountController, only: [:create]
      resources "/tokens", TokenController, only: [:create]
    end

    scope "/v1", V1, as: :v1 do
      pipe_through [:api, :auth]

      # coveralls-ignore-start
      options "/accounts/:id", AccountController, :options
      options "/accounts/withdraw", AccountController, :options
      options "/accounts/deposit", AccountController, :options

      # coveralls-ignore-stop

      resources "/accounts", AccountController, only: [:show], singleton: true do
        post "/withdraw", AccountController, :withdraw
        post "/deposit", AccountController, :deposit
      end
    end
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind auth and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic auth
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    # coveralls-ignore-start
    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BankWeb.Telemetry
    end

    # coveralls-ignore-stop
  end
end
