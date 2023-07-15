defmodule PersonalSiteWeb.Live.Colophon do
  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Colophon")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Colophon</h1>
    <h2 class="text-md">Everything about this website</h2>
    <div>
      <p class="text-sm">This will be expanded upon!</p>
    </div>
    """
  end
end
