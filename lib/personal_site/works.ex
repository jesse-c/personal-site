defmodule PersonalSite.Works do
  alias PersonalSite.Works.Work

  use NimblePublisher,
    build: Work,
    from: Application.app_dir(:personal_site, "priv/works/*.md"),
    as: :works,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options: [footnotes: true]
end
