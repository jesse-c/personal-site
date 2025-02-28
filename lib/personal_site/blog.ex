defmodule PersonalSite.Blog do
  @moduledoc false

  alias PersonalSite.Blog.Post
  alias PersonalSite.MDExConverter

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:personal_site, "priv/blog/posts/*.md"),
    as: :posts,
    html_converter: MDExConverter

  @posts Enum.sort_by(@posts, & &1.date_created, {:desc, Date})

  @tags @posts
        |> Enum.flat_map(& &1.tags)
        |> Enum.uniq()
        |> Enum.sort_by(&String.downcase/1, :asc)

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def all_posts, do: @posts

  def recent_posts(n \\ 5), do: Enum.take(all_posts(), n)

  def get_post_by_slug!(slug) do
    Enum.find(all_posts(), &(&1.slug == slug)) ||
      raise NotFoundError, "post with slug=#{slug} not found"
  end

  def tag_exists!(tag) do
    Enum.member?(all_tags(), tag) ||
      raise NotFoundError, "tag with name=#{tag} not found"
  end

  def all_tags, do: @tags

  def prev_next(post, posts) do
    case Enum.find_index(posts, &(&1 == post)) do
      nil ->
        {:error, :not_found}

      idx ->
        prev = Enum.at(posts, idx + 1)
        # Don't loop around to the start of the list with a -1 index
        next = if idx != 0, do: Enum.at(posts, idx - 1), else: nil

        {:ok, {prev, next}}
    end
  end
end
