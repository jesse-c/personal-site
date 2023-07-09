defmodule PersonalSiteWeb.Live.WorksIndex do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Works

  def inner_mount(_params, _session, socket) do
    updated = assign(socket, works: Works.all_works())

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1>All Works</h1>
    <div>
      <%= for work <- @works do %>
        <div>
          <%= work.title %>
          Tags: <%= Enum.join(work.tags, ", ") %>
        </div>
      <% end %>
    </div>
    """
  end
end
