defmodule PersonalSiteWeb.Live.BlogTagsSingle do
  @moduledoc """
  The blog's tags context single page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Blog

  def inner_mount(params, _session, socket) do
    all_posts = Blog.all_posts()
    all_tags = Blog.all_tags()

    tag = params["id"]

    Blog.tag_exists!(tag)

    years =
      all_posts
      |> Enum.filter(fn post ->
        Enum.member?(post.tags, tag)
      end)
      |> Enum.group_by(& &1.date_created.year)
      |> Enum.sort_by(&elem(&1, 0), :desc)

    updated =
      socket
      |> assign(years: years)
      |> assign(tags: all_tags)
      |> assign(tag: tag)
      |> assign(page_title: "Blog · Tags · #{tag}")

    {:ok, updated}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">
      <.link navigate={~p"/blog"}>Blog</.link>
      · <.link navigate={~p"/blog/tags"}>Tags</.link>
      · {@tag}
    </h1>
    <div class="space-y-3 md:w-1/2 md:max-w-1/2">
      <div :for={{year, posts} <- @years} class="space-y-1">
        <div>{year}</div>
        <div class="space-y-3">
          <div :for={post <- posts} class="space-y-1">
            <p class="text-sm">
              <.link navigate={~p"/blog/#{post.slug}"}>
                {post.title}
              </.link>
            </p>
            <p class="text-xs">
              {post.date_created}
              <%= if post.date_updated do %>
                (updated: {post.date_updated})
              <% end %>
              ･ <PersonalSiteWeb.TagsComponents.inline tags={post.tags} />
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
