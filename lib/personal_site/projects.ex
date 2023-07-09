defmodule PersonalSite.Projects do
  alias PersonalSite.Projects.Project

  use NimblePublisher,
    build: Project,
    from: Application.app_dir(:personal_site, "priv/projects/*.md"),
    as: :projects,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options: [footnotes: true]

  @projects Enum.sort_by(@projects, & &1.date, {:desc, Date})

  @tags @projects |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def all_projects, do: @projects

  def recent_projects(n \\ 5), do: Enum.take(all_projects(), n)

  def get_project_by_slug!(slug) do
    Enum.find(all_projects(), &(&1.slug == slug)) ||
      raise NotFoundError, "project with slug=#{slug} not found"
  end

  def all_tags, do: @tags
end
