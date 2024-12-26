defmodule PersonalSiteWeb.Live.ProjectsIndex do
  @moduledoc """
  The projects context index.
  """

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
      |> assign(page_title: "Projects")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Projects</h1>
    <div class="space-y-3 md:w-1/2 md:max-w-1/2">
      <div :for={{_year, projects} <- @years} class="space-y-1">
        <div class="space-y-3">
          <div :for={project <- projects} class="space-y-1">
            <p class="text-md"><%= project.title %></p>
            <p class="text-xs">
              <.link href={project.source_link}><%= project.source_link %></.link>
            </p>
            <%= if not is_nil(project.external_link) do %>
              <p class="text-xs">
                <.link href={project.external_link}><%= project.external_link %></.link>
              </p>
            <% end %>
            <p class="text-xs"><%= Enum.join(project.tags, ", ") %></p>
            <div class="space-y-3 text-sm">
              <%= raw(project.description) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
