defmodule PersonalSite.Works do
  @moduledoc """
  The works concept.
  """

  alias PersonalSite.Works.Work
  alias PersonalSite.MDEx

  use NimblePublisher,
    build: Work,
    from: Application.app_dir(:personal_site, "priv/works/*.md"),
    as: :works,
    parser: MDEx.Parser,
    html_converter: MDEx.HTMLConverter,
    highlighters: []

  @works Enum.sort_by(@works, & &1.date_start, {:desc, Date})

  @tags @works |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def all_works, do: @works

  def recent_works(n \\ 5), do: Enum.take(all_works(), n)

  def get_work_by_slug!(slug) do
    Enum.find(all_works(), &(&1.slug == slug)) ||
      raise NotFoundError, "work with slug=#{slug} not found"
  end

  def all_tags, do: @tags
end
