defmodule PersonalSiteWeb.Live.ContributionsIndex do
  @moduledoc """
  The contributions context index page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Contributions

  def inner_mount(_params, _session, socket) do
    all_contributions = Contributions.all_contributions()

    years =
      all_contributions
      |> Enum.group_by(& &1.date.year)
      |> Enum.sort_by(&elem(&1, 0), :desc)

    updated =
      socket
      |> assign(years: years)
      |> assign(contributions: Contributions.all_contributions())
      |> assign(page_title: "Contributions")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Contributions</h1>
    <div class="space-y-3 md:w-1/2 md:max-w-1/2">
      <div :for={{_year, contributions} <- @years} class="space-y-1">
        <div class="space-y-3">
          <div :for={contribution <- contributions} class="space-y-1">
            <p class="text-md"><%= contribution.title %></p>
            <p class="text-xs">
              <.link href={contribution.source_link}><%= contribution.source_link %></.link>
            </p>
            <%= if not is_nil(contribution.external_link) do %>
              <p class="text-xs">
                <.link href={contribution.external_link}><%= contribution.external_link %></.link>
              </p>
            <% end %>
            <p class="text-xs"><%= Enum.join(contribution.tags, ", ") %></p>
            <div class="space-y-3 text-sm">
              <%= raw(contribution.description) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
