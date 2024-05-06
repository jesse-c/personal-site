defmodule PersonalSite.Works.Work do
  @moduledoc """
  A work context.
  """

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
    # There
    date_start = Date.from_iso8601!("#{attrs.date_start}-01")

    date_end =
      case attrs.date_end do
        "Current" ->
          attrs.date_end

        date_end ->
          Date.from_iso8601!("#{date_end}-01")
      end

    slug = Slug.slugify(attrs.title)

    fields =
      [
        id: slug,
        slug: slug,
        body: body,
        date_start: date_start,
        date_end: date_end
      ] ++
        (attrs
         |> Map.take(~w(title tags  role description locations)a)
         |> Map.to_list())

    struct!(
      __MODULE__,
      fields
    )
  end

  def date(date)

  def date("Current" = date), do: date

  def date(%Date{} = date), do: Calendar.strftime(date, "%Y-%m")
end
