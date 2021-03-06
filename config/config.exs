# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bank,
  ecto_repos: [Bank.Repo]

# Configures the endpoint
config :bank, BankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PpuasaIQMUrwJsoOPWDYWxFFhr9d0gptIsKyWtazzpnaEYiHrIZwR5CbTr8BrSxO",
  render_errors: [view: BankWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Bank.PubSub,
  live_view: [signing_salt: "dJA7QNbH"]

config :bank, BankWeb.Authentication.Guardian,
  issuer: "bank",
  secret_key: "HhIdoq+T09DC0aXK1mWTgSDT6To/r7u8U74NraaI1egjxMUwM6HIXnen4odlAyI3"

config :bank, :basic_auth,
  username: System.get_env("BACKOFFICE_USER", "bank"),
  password: System.get_env("BACKOFFICE_PASSWORD", "password")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Money
config :money,
  default_currency: :BRL,
  symbol_space: true

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Casex for CamelCase request encoder in Phoenix
config :phoenix, :format_encoders, json: Casex.CamelCaseEncoder

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
