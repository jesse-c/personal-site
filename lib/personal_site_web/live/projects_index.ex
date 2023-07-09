defmodule PersonalSiteWeb.Live.ProjectsIndex do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Projects

  def inner_mount(_params, _session, socket) do
    all_projects = Projects.all_projects()

    years =
      all_projects
      |> Enum.group_by(& &1.date.year)
      |> Enum.sort_by(&elem(&1, 0), :desc)

    updated =
      socket
      |> assign(years: years)
      |> assign(projects: Projects.all_projects())

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1>All Projects</h1>
    <div>
      <%= for {year, projects} <- @years do %>
        <div><%= year %></div>
        <%= for project <- projects do %>
          <div>
            <%= project.title %> - <%= project.date %>
            Tags: <%= Enum.join(project.tags, ", ") %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end
