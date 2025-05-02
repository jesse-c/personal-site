defmodule PersonalSiteWeb.Live.AppsIndex do
  @moduledoc """
  The apps context index.
  """

  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Apps</h1>
    <div class="space-y-3 md:w-1/2 md:max-w-1/2">
      <div class="text-sm">
        <.link href={~p"/apps/instagram-dupe-checker"}>
          <p class="text-md">Instagram Dupe Checker</p>
        </.link>
        <.link href={~p"/apps/kopya"}>
          <p class="text-md">Kopya</p>
        </.link>
      </div>
    </div>
    """
  end
end
