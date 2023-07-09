defmodule PersonalSite.Notes do
  alias PersonalSite.Notes.Note

  use NimblePublisher,
    build: Note,
    from: Application.app_dir(:personal_site, "priv/notes/*.md"),
    as: :notes,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options: [footnotes: true]

  @notes Enum.sort_by(@notes, & &1.date, {:desc, Date})

  @tags @notes |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def all_notes, do: @notes

  def recent_notes(n \\ 5), do: Enum.take(all_notes(), n)

  def get_note_by_slug!(slug) do
    Enum.find(all_notes(), &(&1.slug == slug)) ||
      raise NotFoundError, "note with slug=#{slug} not found"
  end

  def all_tags, do: @tags
end
