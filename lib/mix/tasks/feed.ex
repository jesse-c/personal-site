defmodule Mix.Tasks.Feed do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  alias PersonalSite.Notes

  alias Atomex.Entry
  alias Atomex.Feed

  @root "https://j-e-s-s-e.com"

  def run(_) do
    build_feed(Notes.all_notes())
  end

  def build_feed(notes) do
    Feed.new(@root, DateTime.utc_now(), "Notes · Jesse Claven")
    |> Feed.author("Jesse Claven")
    |> Feed.link(URI.merge(@root, "feed.xml"), rel: "self")
    |> Feed.entries(Enum.map(notes, &get_entry/1))
    |> Feed.build()
    |> Atomex.generate_document()
    |> then(&File.write!("priv/static/feed.xml", &1))
  end

  defp get_entry(note) do
    # Fake writing time for now
    {:ok, datetime, _offset} = DateTime.from_iso8601("#{note.date}T#{~T[00:00:00]}Z")

    Entry.new(
      note.id,
      datetime,
      note.title
    )
    |> Entry.author("Jesse Claven", uri: @root)
    |> Entry.content(note.body, type: "html")
    |> Entry.link(URI.merge(@root, "/notes/#{note.slug}"), rel: "alternate")
    |> Entry.build()
  end
end
