defmodule Bank.Authentication.Guardian do
  @moduledoc false

  use Guardian, otp_app: :bank

  alias Bank.Customers
  alias Bank.Customers.User

  @impl Guardian
  def subject_for_token(%User{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  @impl Guardian
  def resource_from_claims(%{"sub" => id}) do
    {:ok, Customers.get_user!(id)}
  rescue
    Ecto.NoResultsError ->
      {:error, :resource_not_found}
  end
end
