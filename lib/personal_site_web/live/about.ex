defmodule PersonalSiteWeb.Live.About do
  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1>About</h1>
    <div></div>
    """
  end
end
