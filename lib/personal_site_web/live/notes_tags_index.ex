defmodule PersonalSiteWeb.Live.NotesTagsIndex do
  @moduledoc """
  The notes' tags context index page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Notes

  def inner_mount(_params, _session, socket) do
    all_notes = Notes.all_notes()
    all_tags = Notes.all_tags()

    freqs_tags = all_notes |> Enum.flat_map(& &1.tags) |> Enum.frequencies()

    updated =
      socket
      |> assign(notes: all_notes)
      |> assign(tags: all_tags)
      |> assign(freqs_tags: freqs_tags)
      |> assign(page_title: "Notes · Tags")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">
      <.link navigate={~p"/notes"}>Notes</.link> · <.link navigate={~p"/notes/tags"}>Tags</.link>
    </h1>
    <div class="space-y-3 mt-3">
      <p class="text-sm">Sorted alphabetically</p>
      <div class="space-y-1 text-sm">
        <div :for={tag <- @tags}>
          <p class="text-sm">
            <.link navigate={~p"/notes/tags/#{tag}"}>
              <%= tag %><span class="sup pl-0.5"><%= @freqs_tags[tag] %></span>
            </.link>
          </p>
        </div>
      </div>
    </div>
    """
  end
end
