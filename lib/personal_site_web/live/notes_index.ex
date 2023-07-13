defmodule PersonalSiteWeb.Live.NotesIndex do
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
      |> assign(notes: Notes.all_notes())
      |> assign(page_title: "Notes")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">Notes</h1>
    <div class="space-y-3">
      <div :for={{year, notes} <- @years} class="space-y-1">
        <div><%= year %></div>
        <div class="space-y-3">
          <div :for={note <- notes} class="space-y-1">
            <p class="text-sm">
              <.link class="hover:underline" navigate={~p"/notes/#{note.slug}"}>
                <%= note.title %>
              </.link>
            </p>
            <p class="text-xs"><%= note.date %> ･ <%= Enum.join(note.tags, ", ") %></p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
