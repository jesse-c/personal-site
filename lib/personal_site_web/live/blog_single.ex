defmodule PersonalSiteWeb.Live.BlogSingle do
  @moduledoc """
  The blog post context single page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Cursors
  alias PersonalSite.Blog
  alias PersonalSiteWeb.Endpoint

  @trunc_len_chars 40

  def inner_mount(params, _session, socket) do
    post = Blog.get_post_by_slug!(params["id"])

    updated =
      socket
      |> assign(post: post)
      |> assign(page_title: "#{post.title} · post")
      |> then(fn socket ->
        {prev, next} =
          case Blog.prev_next(post, socket.assigns[:posts]) do
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
    <div class="post space-y-3">
      <h1 class="text-lg"><%= @post.title %></h1>
      <p class="text-xs">
        <%= @post.date %> ･ <PersonalSiteWeb.TagsComponents.inline tags={@post.tags} />
      </p>
      <div class="space-y-3">
        <%= raw(@post.body) %>
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
          <.link navigate={~p"/blog/#{@prev.slug}"} title={@prev.title}>
            ← <%= truncate(@prev.title) %>
          </.link>
        </div>
      <% end %>
      <%= if not is_nil(@next) do %>
        <div class="float-right">
          <.link navigate={~p"/blog/#{@next.slug}"} title={@next.title}>
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
