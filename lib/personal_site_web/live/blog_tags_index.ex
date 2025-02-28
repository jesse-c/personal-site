defmodule PersonalSiteWeb.Live.BlogTagsIndex do
  @moduledoc """
  The blog's tags context index page.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Blog

  def inner_mount(_params, _session, socket) do
    all_posts = Blog.all_posts()
    all_tags = Blog.all_tags()

    freqs_tags = all_posts |> Enum.flat_map(& &1.tags) |> Enum.frequencies()

    updated =
      socket
      |> assign(posts: all_posts)
      |> assign(tags: all_tags)
      |> assign(freqs_tags: freqs_tags)
      # Default sort method
      |> assign(sort_by: :alphabetical)
      |> assign(page_title: "Blog · Tags")

    {:ok, updated}
  end

  def handle_event("sort", %{"sort_by" => sort_by}, socket) do
    {:noreply, assign(socket, sort_by: String.to_existing_atom(sort_by))}
  end

  defp sorted_tags(tags, freqs_tags, posts, sort_by)

  defp sorted_tags(tags, _freqs_tags, _posts, :alphabetical), do: Enum.sort(tags)

  defp sorted_tags(tags, freqs_tags, _posts, :frequency),
    do: Enum.sort_by(tags, fn tag -> freqs_tags[tag] end, :desc)

  defp sorted_tags(tags, _freqs_tags, posts, :recent),
    do:
      Enum.sort_by(
        tags,
        fn tag ->
          posts
          |> Enum.filter(fn post -> tag in post.tags end)
          |> Enum.map(fn post -> post.date_updated || post.date_created end)
          |> Enum.max(Date)
        end,
        {:desc, Date}
      )

  def render(assigns) do
    sorted_tags = sorted_tags(assigns.tags, assigns.freqs_tags, assigns.posts, assigns.sort_by)
    assigns = assign(assigns, :sorted_tags, sorted_tags)

    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">
      <.link navigate={~p"/blog"}>Blog</.link> · <.link navigate={~p"/blog/tags"}>Tags</.link>
    </h1>
    <div class="space-y-3 mt-3">
      <div class="text-sm">
        <button
          phx-click="sort"
          phx-value-sort_by="alphabetical"
          class="border border-solid rounded-sm border-black dark:border-white hover:bg-black dark:hover:bg-white text-black dark:text-white hover:text-white dark:hover:text-black transition-colors py-1 px-1 text-xs max-w-fit"
        >
          Alphabetical
        </button>
        <button
          phx-click="sort"
          phx-value-sort_by="frequency"
          class="border border-solid rounded-sm border-black dark:border-white hover:bg-black dark:hover:bg-white text-black dark:text-white hover:text-white dark:hover:text-black transition-colors py-1 px-1 text-xs max-w-fit"
        >
          Post count
        </button>
        <button
          phx-click="sort"
          phx-value-sort_by="recent"
          class="border border-solid rounded-sm border-black dark:border-white hover:bg-black dark:hover:bg-white text-black dark:text-white hover:text-white dark:hover:text-black transition-colors py-1 px-1 text-xs max-w-fit"
        >
          Most recent
        </button>
      </div>
      <div class="space-y-1 text-sm">
        <div :for={tag <- @sorted_tags}>
          <p class="text-sm">
            <.link navigate={~p"/blog/tags/#{tag}"}>
              {tag}<span class="sup pl-0.5"><%= @freqs_tags[tag] %></span>
            </.link>
          </p>
        </div>
      </div>
    </div>
    """
  end
end
