defmodule PersonalSite.Contributions do
  @moduledoc """
  The contributions concept.
  """

  alias PersonalSite.Contributions.Contribution
  alias PersonalSite.MDEx

  use NimblePublisher,
    build: Contribution,
    from: Application.app_dir(:personal_site, "priv/contributions/*.md"),
    as: :contributions,
    parser: MDEx.Parser,
    html_converter: MDEx.HTMLConverter,
    highlighters: []

  @contributions Enum.sort_by(@contributions, & &1.date, {:desc, Date})

  @tags @contributions |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def all_contributions, do: @contributions

  def recent_contributions(n \\ 5), do: Enum.take(all_contributions(), n)

  def get_contribution_by_slug!(slug) do
    Enum.find(all_contributions(), &(&1.slug == slug)) ||
      raise NotFoundError, "contribution with slug=#{slug} not found"
  end

  def all_tags, do: @tags
end
