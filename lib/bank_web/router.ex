defmodule BankWeb.Router do
  @moduledoc false

  use BankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authentication do
    plug Bank.Authentication.Pipeline
  end

  pipeline :ensure_authentication do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api", BankWeb, as: :api do
    scope "/v1", V1, as: :v1 do
      pipe_through [:api, :authentication]

      resources "/users", UserController, only: [:create]
    end

    scope "/v1", V1, as: :v1 do
      pipe_through [:api, :authentication, :ensure_authentication]

      resources "/users", UserController, only: [:show]
      resources "/accounts", AccountController, only: [:show]
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BankWeb.Telemetry
    end
  end
end
