defmodule PersonalSiteWeb.Live.WorksIndex do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Works

  def inner_mount(_params, _session, socket) do
    updated =
      socket
      |> assign(works: Works.all_works())
      |> assign(page_title: "Works")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Works</h1>
    <div class="space-y-3">
      <div :for={work <- @works} class="space-y-1">
        <p class="text-sm"><%= work.title %></p>
        <p class="text-xs"><%= work.role %></p>
        <p class="text-xs"><%= work.date_start %> — <%= work.date_end %></p>
        <p class="text-xs"><%= work.description %></p>
        <p class="text-xs"><%= Enum.join(work.tags, ", ") %></p>
      </div>
    </div>
    """
  end
end
