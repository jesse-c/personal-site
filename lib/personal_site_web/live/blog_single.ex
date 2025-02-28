defmodule PersonalSiteWeb.Live.BlogSingle do
  @moduledoc """
  The blog post context single page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Cursors
  alias PersonalSite.Blog
  alias PersonalSiteWeb.Endpoint

  @trunc_len_chars 40

  def inner_mount(params, _session, socket), do: maybe_redirect(params["id"], socket)

  def maybe_redirect(slug, socket)

  def maybe_redirect("initial-release-of-semantic-search-for-notes-app", socket),
    do: {:ok, push_navigate(socket, to: ~p"/blog/initial-release-of-hybrid-search-for-notes-app")}

  def maybe_redirect(slug, socket) do
    post = Blog.get_post_by_slug!(slug)

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
    <div class="post space-y-3 md:w-1/2 md:max-w-1/2">
      <h1 class="text-lg">{@post.title}</h1>
      <p class="text-xs">
        {@post.date_created}
        <%= if @post.date_updated do %>
          (updated: {@post.date_updated})
        <% end %>
        ･ <PersonalSiteWeb.TagsComponents.inline tags={@post.tags} />
      </p>
      <div class="space-y-3">
        {raw(@post.body)}
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
    <div class="flex flex-col md:flex-row text-xs">
      <%= if not is_nil(@prev) do %>
        <div class="w-full md:w-1/2 text-left">
          <.link navigate={~p"/blog/#{@prev.slug}"} title={@prev.title} class="truncate">
            ← {truncate(@prev.title)}
          </.link>
        </div>
      <% end %>
      <%= if not is_nil(@next) do %>
        <div class="w-full md:w-1/2 text-right">
          <.link navigate={~p"/blog/#{@next.slug}"} title={@next.title} class="truncate">
            {truncate(@next.title)} →
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
