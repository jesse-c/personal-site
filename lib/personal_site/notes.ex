defmodule PersonalSite.Notes do
  @moduledoc """
  The notes concept.
  """

  alias PersonalSite.Notes.Note

  use NimblePublisher,
    build: Note,
    from: Application.app_dir(:personal_site, "priv/notes/*.md"),
    as: :notes,
    highlighters: [
      :makeup_diff,
      :makeup_elixir,
      :makeup_erlang,
      :makeup_json,
      :makeup_rust,
      :makeup_sql
    ],
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

  def prev_next(note, notes) do
    case Enum.find_index(notes, &(&1 == note)) do
      nil ->
        {:error, :not_found}

      idx ->
        prev = Enum.at(notes, idx + 1)
        # Don't loop around to the start of the list with a -1 index
        next = if idx != 0, do: Enum.at(notes, idx - 1), else: nil

        {:ok, {prev, next}}
    end
  end
end
