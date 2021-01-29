defmodule BankWeb.Authentication.ErrorHandler do
  @moduledoc false

  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, resp_body(type))
  end

  defp resp_body(type) do
    detail =
      type
      |> to_string()
      |> String.capitalize()

    Jason.encode!(%{errors: %{detail: detail}})
  end
end
