defmodule PersonalSiteWeb.Live.Blog.Redirects do
  @moduledoc """
  The blog post redirects for the previous structure and for typos.
  """

  # Get the ~p sigil
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Blog

  def maybe_redirect(slug, socket)

  def maybe_redirect("kopya-release", socket),
    do: {:ok, push_navigate(socket, to: ~p"/blog/alpha-release-of-kopya")}

  def maybe_redirect("initial-release-of-semantic-search-for-notes-app", socket),
    do: {:ok, push_navigate(socket, to: ~p"/blog/initial-release-of-hybrid-search-for-notes-app")}

  def maybe_redirect("v1-of-raycast-extension-for-himalaya", socket),
    do: {:ok, push_navigate(socket, to: ~p"/blog/v1-of-raycast-extension-for-himalaya-released")}

  def maybe_redirect("using-autumn-with-nimblepublisher-for-synax-highlighting", socket),
    do:
      {:ok,
       push_navigate(socket,
         to: ~p"/blog/using-autumn-with-nimblepublisher-for-syntax-highlighting"
       )}

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
