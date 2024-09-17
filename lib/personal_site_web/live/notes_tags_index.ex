defmodule PersonalSiteWeb.Live.NotesTagsIndex do
  @moduledoc """
  The notes' tags context index page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Notes

  def inner_mount(_params, _session, socket) do
    all_notes = Notes.all_notes()
    all_tags = Notes.all_tags()

    years =
      all_notes
      |> Enum.group_by(& &1.date.year)
      |> Enum.sort_by(&elem(&1, 0), :desc)

    updated =
      socket
      |> assign(years: years)
      |> assign(notes: all_notes)
      |> assign(tags: all_tags)
      |> assign(page_title: "Notes · Tags")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Notes · Tags</h1>
    <div class="space-y-3">
      <p class="text-sm">Sorted alphabetically</p>
      <div class="space-y-1 text-sm">
        <div :for={tag <- @tags}>
          <p class="text-sm">
            <.link navigate={~p"/notes/tags/#{tag}"}>
              <%= tag %>
            </.link>
          </p>
        </div>
      </div>
    </div>
    """
  end
end
