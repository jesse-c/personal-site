defmodule PersonalSite.Projects do
  alias PersonalSite.Projects.Project

  use NimblePublisher,
    build: Project,
    from: Application.app_dir(:personal_site, "priv/projects/*.md"),
    as: :projects,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options: [footnotes: true]
end
