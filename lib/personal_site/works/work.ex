defmodule PersonalSite.Works.Work do
  @enforce_keys [
    :id,
    :title,
    :slug,
    :tags,
    :body,
    :date_start,
    :date_end,
    :role,
    :description,
    :locations
  ]
  defstruct [
    :id,
    :title,
    :slug,
    :tags,
    :body,
    :date_start,
    :date_end,
    :role,
    :description,
    :locations
  ]

  @type t() :: any()

  def build(_filename, attrs, body) do
    slug = Slug.slugify(attrs.title)

    fields =
      [
        id: slug,
        slug: slug,
        body: body
      ] ++
        (attrs
         |> Map.take(~w(title tags date_start date_end role description locations)a)
         |> Map.to_list())

    struct!(
      __MODULE__,
      fields
    )
  end
end
