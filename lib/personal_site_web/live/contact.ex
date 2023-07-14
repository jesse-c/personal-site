defmodule PersonalSiteWeb.Live.Contact do
  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Contact")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1>Contact</h1>
    I’m available through <a rel="me" href="https://mastodon.social/@jqk">Mastodon ↗</a>
    for mixed chat and
    <a href="https://github.com/jesse-c" target="_blank">GitHub ↗</a> for various projects/contributions and collaboration.
    """
  end
end
