defmodule PersonalSite.MDEx do
  @moduledoc """
  A new Markdown converter and highlighter.
  """

  defmodule Parser do
    @moduledoc false

    def parse(_path, contents) do
      parts = String.split(contents, "---\n", trim: true, parts: 2)
      header = Enum.at(parts, 0)
      # May be empty, if for a contribution
      markdown_body = Enum.at(parts, 1, "")

      {%{} = attrs, _} = Code.eval_string(header, [])
      html_body = markdown_to_html!(markdown_body)

      {attrs, html_body}
    end

    defp markdown_to_html!(markdown_body) do
      MDEx.to_html!(markdown_body,
        syntax_highlight: [formatter: {:html_inline, theme: "github_dark"}],
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
      )
    end
  end

  defmodule HTMLConverter do
    @moduledoc false

    # ⚠️ Important ⚠️
    # You need to provide a custom converter, because otherwise NimblePublisher
    # will apply their default markdown -> HTML conversion which will
    # interfere with MDEx's conversion.
    def convert(_extname, body, _attrs, _opts), do: body
  end
end
