defmodule PersonalSite.MDExConverter do
  @moduledoc """
  A new Markdown converter and highlighter.
  """

  def convert(filepath, body, _attrs, _opts) do
    if Path.extname(filepath) in [".md", ".markdown"] do
      opts = [
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
          escape: true,
          hardbreaks: true
        ]
      ]

      MDEx.to_html!(body, opts)
    end
  end
end
