defmodule BankWeb.Router do
  @moduledoc false

  use BankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug BankWeb.Authentication.Pipeline
  end

  scope "/api", BankWeb, as: :api do
    scope "/v1", V1, as: :v1 do
      pipe_through :api

      resources "/users", UserController, only: [:create], singleton: true do
        post "/authenticate", UserController, :authenticate
      end
    end

    scope "/v1", V1, as: :v1 do
      pipe_through [:api, :auth]

      resources "/users", UserController, only: [:show]
      resources "/accounts", AccountController, only: [:show]
    end
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

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BankWeb.Telemetry
    end
  end
end
