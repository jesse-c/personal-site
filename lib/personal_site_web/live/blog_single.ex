defmodule PersonalSiteWeb.Live.BlogSingle do
  @moduledoc """
  The blog post context single page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Cursors
  alias PersonalSite.Blog
  alias PersonalSiteWeb.Endpoint
  alias PersonalSiteWeb.Live.Blog.Redirects

  @trunc_len_chars 40

  def inner_mount(params, _session, socket), do: Redirects.maybe_redirect(params["id"], socket)

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
