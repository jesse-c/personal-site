defmodule PersonalSiteWeb.Live.NotesSingle do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Cursors
  alias PersonalSite.Notes
  alias PersonalSiteWeb.Endpoint
  alias PersonalSiteWeb.Presence

  def inner_mount(params, _session, socket) do
    note = Notes.get_note_by_slug!(params["id"])

    updated =
      socket
      |> assign(note: note)
      |> assign(page_title: "#{note.title} · Note")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <div class="note space-y-3">
      <h1 class="text-lg"><%= @note.title %></h1>
      <p class="text-xs"><%= @note.date %> ･ <%= Enum.join(@note.tags, ", ") %></p>
      <div class="space-y-1">
        <%= raw(@note.body) %>
      </div>
    </div>
    """
  end
end
