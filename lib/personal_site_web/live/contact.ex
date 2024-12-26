defmodule PersonalSiteWeb.Live.Contact do
  @moduledoc """
  The contact context page.
  """

  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Contact")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Contact</h1>
    <div class="md:w-1/2 md:max-w-1/2">
      <p class="text-sm">
        I’m available through
        <a rel="me" href="https://mastodon.social/@jqk" target="_blank">Mastodon ↗</a>
        and <a href="https://bsky.app/profile/lzp.bsky.social" target="_blank">Bluesky ↗</a>
        for mixed chat and <a href="https://github.com/jesse-c" target="_blank">GitHub ↗</a>
        for various projects/contributions and collaboration.
      </p>
    </div>
    """
  end
end
