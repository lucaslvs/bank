import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bank, Bank.Repo,
  username: System.get_env("DATABASE_USERNAME", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  database: "bank_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("DATABASE_HOSTNAME", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank, BankWeb.Endpoint,
  http: [port: 4002],
  server: false

config :bank, Bank.Notifications.Mailer, adapter: Bamboo.TestAdapter

# Speed up tests with Argon2 encryption
config :argon2_elixir, t_cost: 1, m_cost: 8

# Print only warnings and errors during test
config :logger, level: :warn
