defmodule Mix.Tasks.Sitemap do
  @moduledoc "Task to build the sitemap: `mix help sitemap` or `mix sitemap`"
  use Mix.Task

  alias PersonalSite.Blog

  @root "https://www.j-e-s-s-e.com"

  def run(_) do
    static_paths = discover_static_routes()
    posts = Blog.all_posts()
    tags = Blog.all_tags()

    xml = build_sitemap(static_paths, posts, tags)
    File.write!("priv/static/sitemap.xml", xml)
    File.write!("priv/static/sitemap.xml.gz", :zlib.gzip(xml))

    IO.puts(
      "Generated priv/static/sitemap.xml with #{length(static_paths)} static routes, #{length(posts)} posts, #{length(tags)} tags"
    )
  end

  # Discovers static (no path params) browser-pipeline LiveView routes from the router.
  # Only LiveView routes are included — regular controller routes (redirects, feeds, etc.)
  # are automatically excluded because they don't define __live__/0.
  defp discover_static_routes do
    PersonalSiteWeb.Router.__routes__()
    |> Enum.filter(&live_view_page_route?/1)
    |> Enum.map(& &1.path)
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp live_view_page_route?(route) do
    route.verb == :get &&
      not String.contains?(route.path, ":") &&
      route.plug == Phoenix.LiveView.Plug
  end

  def build_sitemap(static_paths, posts, tags) do
    urls =
      Enum.map(static_paths, fn path ->
        "  <url>\n    <loc>#{@root}#{path}</loc>\n  </url>"
      end) ++
        Enum.map(posts, fn post ->
          lastmod = post.date_updated || post.date_created

          "  <url>\n    <loc>#{@root}/blog/#{escape_xml(post.slug)}</loc>\n    <lastmod>#{lastmod}</lastmod>\n  </url>"
        end) ++
        Enum.map(tags, fn tag ->
          "  <url>\n    <loc>#{@root}/blog/tags/#{escape_xml(tag)}</loc>\n  </url>"
        end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{Enum.join(urls, "\n")}
    </urlset>
    """
  end

  defp escape_xml(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end
end
