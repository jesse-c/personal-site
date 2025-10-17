defmodule Mix.Tasks.Feed do
  @moduledoc "Task to build the RSS feed of blog posts: `mix help feed` or `mix feed`"
  use Mix.Task

  alias PersonalSite.Blog

  alias Atomex.Entry
  alias Atomex.Feed

  @root "https://j-e-s-s-e.com"

  def run(_) do
    build_feed(Blog.all_posts())
  end

  def build_feed(posts) do
    Feed.new(@root, DateTime.utc_now(), "Blog · Jesse Claven")
    |> Feed.author("Jesse Claven")
    |> Feed.link(URI.merge(@root, "feed.xml"), rel: "self")
    |> Feed.entries(Enum.map(posts, &get_entry/1))
    |> Feed.build()
    |> Atomex.generate_document()
    |> then(&File.write!("priv/static/feed.xml", &1))
  end

  defp get_entry(post) do
    # Fake writing time for now
    {:ok, datetime, _offset} = DateTime.from_iso8601("#{post.date_created}T#{~T[00:00:00]}Z")

    Entry.new(
      post.id,
      datetime,
      post.title
    )
    |> Entry.author("Jesse Claven", uri: @root)
    |> Entry.content(post.body, type: "html")
    |> Entry.link(URI.merge(@root, "/blog/#{post.slug}"), rel: "alternate")
    |> Entry.build()
  end
end
