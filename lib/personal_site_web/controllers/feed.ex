defmodule PersonalSiteWeb.FeedController do
  use PersonalSiteWeb, :controller

  # Ideally this would be served using Plug.Static but I had issues with
  # that.
  def index(conn, _params) do
    path = Path.join(Application.app_dir(:personal_site), "priv/static/feed.xml")
    {:ok, body} = File.read(path)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, body)
  end
end
