defmodule PersonalSiteWeb.Live.NotesSingle do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Cursors
  alias PersonalSite.Notes
  alias PersonalSiteWeb.Endpoint
  alias PersonalSiteWeb.Presence

  def inner_mount(params, _session, socket) do
    updated = assign(socket, note: Notes.get_note_by_slug!(params["id"]))

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1><%= @note.title %></h1>
    <div>
      <%= raw(@note.body) %>
    </div>
    """
  end
end