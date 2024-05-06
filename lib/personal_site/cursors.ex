defmodule PersonalSite.Cursors do
  @moduledoc """
  Cursors context.
  """

  @topic "cursors"

  def topic, do: @topic

  def get_hsl(s) do
    hue = s |> to_charlist() |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
