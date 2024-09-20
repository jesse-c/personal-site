defmodule PersonalSiteWeb.Live.NotesSingle do
  @moduledoc """
  The notes context single page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Cursors
  alias PersonalSite.Notes
  alias PersonalSiteWeb.Endpoint

  @trunc_len_chars 40

  def inner_mount(params, _session, socket) do
    note = Notes.get_note_by_slug!(params["id"])

    updated =
      socket
      |> assign(note: note)
      |> assign(page_title: "#{note.title} · Note")
      |> then(fn socket ->
        {prev, next} =
          case Notes.prev_next(note, socket.assigns[:notes]) do
            {:error, :not_found} -> {nil, nil}
            {:ok, {prev, next}} -> {prev, next}
          end

        # Always assign something to simplify rendering for the component
        assign(socket, prev: prev, next: next)
      end)

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <div class="note space-y-3">
      <h1 class="text-lg"><%= @note.title %></h1>
      <p class="text-xs">
        <%= @note.date %> ･ <PersonalSiteWeb.TagsComponents.inline tags={@note.tags} />
      </p>
      <div class="space-y-3">
        <%= raw(@note.body) %>
      </div>
      <.prev_next prev={assigns[:prev]} next={assigns[:next]} />
    </div>
    """
  end

  defp prev_next(assigns) do
    ~H"""
    <div>
      <hr />
    </div>
    <div class="text-xs">
      <%= if not is_nil(@prev) do %>
        <div class="float-left">
          <.link navigate={~p"/notes/#{@prev.slug}"} title={@prev.title}>
            ← <%= truncate(@prev.title) %>
          </.link>
        </div>
      <% end %>
      <%= if not is_nil(@next) do %>
        <div class="float-right">
          <.link navigate={~p"/notes/#{@next.slug}"} title={@next.title}>
            <%= truncate(@next.title) %> →
          </.link>
        </div>
      <% end %>
    </div>
    """
  end

  defp truncate(string) do
    if String.length(string) > @trunc_len_chars do
      "#{String.slice(string, 0, @trunc_len_chars)}…"
    else
      string
    end
  end
end
