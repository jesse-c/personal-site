defmodule PersonalSite.MDExConverter do
  @moduledoc """
  A new Markdown converter and highlighter.
  """

  def convert(filepath, body, _attrs, _opts) do
    if Path.extname(filepath) in [".md", ".markdown"] do
      opts = [extension: [footnotes: true]]

      MDEx.to_html(body, opts)
    end
  end
end
