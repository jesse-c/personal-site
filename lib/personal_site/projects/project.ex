defmodule PersonalSite.Projects.Project do
  @enforce_keys [
    :id,
    :title,
    :slug,
    :date,
    :tags,
    :body,
    :source_link,
    :description
  ]
  defstruct [
    :id,
    :title,
    :slug,
    :date,
    :tags,
    :body,
    :source_link,
    :external_link,
    :description
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
      ] ++
        (attrs
         |> Map.take(~w(title tags source_link external_link description)a)
         |> Map.to_list())

    struct!(
      __MODULE__,
      fields
    )
  end
end
