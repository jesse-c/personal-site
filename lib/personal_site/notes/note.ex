defmodule PersonalSite.Notes.Note do
  @moduledoc """
  A note context.
  """

  @enforce_keys [
    :id,
    :title,
    :slug,
    :date,
    :tags,
    :body
  ]
  defstruct [
    :id,
    :title,
    :slug,
    :date,
    :tags,
    :body
  ]

  @type t() :: any()

  def build(_filename, attrs, body) do
    date = Date.from_iso8601!(attrs.date)

    slug = Slug.slugify(attrs.title)

    fields =
      [
        id: slug,
        slug: slug,
        date: date,
        body: body
      ] ++ (attrs |> Map.take(~w(title tags)a) |> Map.to_list())

    struct!(
      __MODULE__,
      fields
    )
  end
end
