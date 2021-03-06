defmodule BankWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BankWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, operation, %Ecto.Changeset{} = changeset, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankWeb.ChangesetView)
    |> render("error.json", operation: operation, changeset: changeset)
  end

  def call(conn, {:error, operation, message, _}) when is_binary(message) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankWeb.ErrorView)
    |> render("error.json", operation: operation, message: message)
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankWeb.ErrorView)
    |> render("error.json", message: message)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BankWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BankWeb.ErrorView)
    |> render(:"401")
  end

  def call(conn, _error) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(BankWeb.ErrorView)
    |> render(:"500")
  end
end
