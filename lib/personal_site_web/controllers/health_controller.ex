defmodule PersonalSiteWeb.HealthController do
  use PersonalSiteWeb, :controller

  def healthz(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "ok"})
  end
end
