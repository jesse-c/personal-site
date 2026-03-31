defmodule PersonalSite.MDExConverter do
  @moduledoc """
  A new Markdown converter and highlighter.
  """

  def convert(filepath, body, _attrs, _opts) do
    if Path.extname(filepath) in [".md", ".markdown"] do
      MDEx.new(
        markdown: body,
        extension: [
          strikethrough: true,
          underline: true,
          tagfilter: true,
          table: true,
          autolink: true,
          tasklist: true,
          footnotes: true,
          shortcodes: true
        ],
        parse: [
          smart: true,
          relaxed_tasklist_matching: true,
          relaxed_autolinks: true
        ],
        render: [
          github_pre_lang: true,
          hardbreaks: true,
          # Allow raw HTML (e.g. <details>/<summary>) and codefence
          # renderer SVG output to pass through unescaped.
          unsafe: true
        ]
      )
      |> MDEx.to_html!(codefence_renderers: %{"d2" => PersonalSite.MDExD2.renderer()})
    end
  end
end
