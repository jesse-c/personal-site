defmodule PersonalSiteWeb.Live.NotesIndex do
  @moduledoc """
  The notes context index page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Notes

  def inner_mount(_params, _session, socket) do
    all_notes = Notes.all_notes()

    years =
      all_notes
      |> Enum.group_by(& &1.date.year)
      |> Enum.sort_by(&elem(&1, 0), :desc)

    updated =
      socket
      |> assign(years: years)
      |> assign(page_title: "Notes")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg"><.link navigate={~p"/notes"}>Notes</.link></h1>
    <div class="space-y-3 mt-3">
      <p class="text-sm"><.link navigate={~p"/notes/tags"}>All tags</.link></p>
      <div :for={{year, notes} <- @years} class="space-y-1">
        <div><%= year %></div>
        <div class="space-y-3">
          <div :for={note <- notes} class="space-y-1">
            <p class="text-sm">
              <.link navigate={~p"/notes/#{note.slug}"}>
                <%= note.title %>
              </.link>
            </p>
            <p class="text-xs">
              <%= note.date %> ･ <PersonalSiteWeb.TagsComponents.inline tags={note.tags} />
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
