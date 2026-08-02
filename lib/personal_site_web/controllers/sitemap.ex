defmodule PersonalSiteWeb.SitemapController do
  use PersonalSiteWeb, :controller

  def index(conn, _params) do
    path = Path.join(Application.app_dir(:personal_site), "priv/static/sitemap.xml")
    {:ok, body} = File.read(path)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, body)
  end

  def index_gz(conn, _params) do
    path = Path.join(Application.app_dir(:personal_site), "priv/static/sitemap.xml.gz")
    {:ok, body} = File.read(path)

    conn
    |> put_resp_content_type("application/xml")
    |> put_resp_header("content-encoding", "gzip")
    |> send_resp(200, body)
  end
end
