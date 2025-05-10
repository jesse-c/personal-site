defmodule PersonalSiteWeb.Live.Blog.Redirects do
  @moduledoc """
  The blog post redirects for the previous structure and for typos.
  """

  # Get the ~p sigil
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Blog

  @redirects_maps %{
    "kopya-release" => "alpha-release-of-kopya",
    "initial-release-of-semantic-search-for-notes-app" =>
      "initial-release-of-hybrid-search-for-notes-app",
    "v1-of-raycast-extension-for-himalaya" => "v1-of-raycast-extension-for-himalaya-released",
    "using-autumn-with-nimblepublisher-for-synax-highlighting" =>
      "using-autumn-with-nimblepublisher-for-syntax-highlighting",
    "notes-app-hybrid-search-release" => "initial-release-of-hybrid-search-for-notes-app",
    "serialise-deserialise-enum-from-rust-to-swift" =>
      "serialise-and-deserialise-enums-with-named-associated-values-from-rust-swift"
  }

  def maybe_redirect(slug, socket)

  def maybe_redirect(slug, socket) when is_map_key(@redirects_maps, slug),
    do: {:ok, push_navigate(socket, to: ~p"/blog/#{@redirects_maps[slug]}")}

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
end
