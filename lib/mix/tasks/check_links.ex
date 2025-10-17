defmodule Mix.Tasks.CheckLinks do
  @moduledoc "Check for broken internal blog post links"

  use Mix.Task

  alias PersonalSite.Blog

  def run(_) do
    posts = Blog.all_posts()
    all_slugs = MapSet.new(posts, & &1.slug)

    broken_links =
      Enum.flat_map(posts, fn post ->
        post.body
        |> extract_internal_links()
        |> Enum.reject(&MapSet.member?(all_slugs, &1))
        |> Enum.map(&{post.slug, &1})
      end)

    absolute_links =
      Enum.flat_map(posts, fn post ->
        post.body
        |> extract_absolute_blog_links()
        |> Enum.map(&{post.slug, &1})
      end)

    has_broken = broken_links != []
    has_absolute = absolute_links != []

    if has_broken do
      Mix.shell().error("✗ Found #{length(broken_links)} broken internal blog link(s):")

      Enum.each(broken_links, fn {post_slug, broken_slug} ->
        Mix.shell().error("  - Post '#{post_slug}' links to non-existent '#{broken_slug}'")
      end)
    end

    if has_absolute do
      if has_broken, do: Mix.shell().error("")

      Mix.shell().error(
        "✗ Found #{length(absolute_links)} absolute /blog/ link(s) (use relative slugs):"
      )

      Enum.each(absolute_links, fn {post_slug, link} ->
        slug = String.trim_leading(link, "/blog/")
        Mix.shell().error("  - Post '#{post_slug}' uses '#{link}' (should be '#{slug}')")
      end)
    end

    if not has_broken and not has_absolute do
      Mix.shell().info("✓ All internal blog links are valid")
    end

    if has_broken or has_absolute, do: System.halt(1)
  end

  def extract_internal_links(html_body) do
    relative_slugs =
      ~r/href="([^"]+)"/
      |> Regex.scan(html_body, capture: :all_but_first)
      |> List.flatten()
      |> Enum.filter(&relative_slug?/1)

    absolute_slugs =
      html_body
      |> extract_absolute_blog_links()
      |> Enum.map(&String.trim_leading(&1, "/blog/"))

    relative_slugs ++ absolute_slugs
  end

  defp relative_slug?(href) do
    not String.contains?(href, "://") and
      not String.starts_with?(href, "/") and
      not String.starts_with?(href, "#") and
      String.match?(href, ~r/^[a-z0-9\-]+$/)
  end

  def extract_absolute_blog_links(html_body) do
    ~r/href="([^"]+)"/
    |> Regex.scan(html_body, capture: :all_but_first)
    |> List.flatten()
    |> Enum.filter(&String.starts_with?(&1, "/blog/"))
  end
end
