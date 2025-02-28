defmodule PersonalSite.Blog.Post do
  @moduledoc """
  A post context.
  """

  @enforce_keys [
    :id,
    :title,
    :slug,
    :date_created,
    :date_updated,
    :tags,
    :body
  ]
  defstruct [
    :id,
    :title,
    :slug,
    :date_created,
    :date_updated,
    :tags,
    :body
  ]

  @type t() :: any()

  def build(_filename, attrs, body) do
    date_created = Date.from_iso8601!(attrs.date_created)

    date_updated =
      Map.get(attrs, :date_updated)
      |> then(fn
        nil -> nil
        date_str -> Date.from_iso8601!(date_str)
      end)

    slug = Slug.slugify(attrs.title)

    fields =
      [
        id: slug,
        slug: slug,
        date_created: date_created,
        date_updated: date_updated,
        body: body
      ] ++ (attrs |> Map.take(~w(title tags)a) |> Map.to_list())

    struct!(
      __MODULE__,
      fields
    )
  end
end
