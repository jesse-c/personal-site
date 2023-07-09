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

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1>All Notes</h1>
    <div>
      <%= for {year, notes} <- @years do %>
        <div><%= year %></div>
        <%= for note <- notes do %>
          <div>
            <.link navigate={~p"/notes/#{note}"}><%= note.title %> - <%= note.date %></.link>
            Tags: <%= Enum.join(note.tags, ", ") %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end
