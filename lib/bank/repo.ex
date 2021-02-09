defmodule Bank.Repo do
  use Ecto.Repo,
    otp_app: :bank,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20

  @impl Ecto.Repo
  def init(_type, config) do
    {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
  end
end
