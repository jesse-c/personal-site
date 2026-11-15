defmodule PersonalSite.MDExConverterTest do
  use ExUnit.Case, async: true

  alias PersonalSite.MDExConverter

  test "code blocks retain dual-theme colors, line numbers, and escaped source" do
    source = ~s|IO.puts("<hello>")|
    html = MDExConverter.convert("example.md", "```elixir\n#{source}\n```", %{}, [])
    document = Floki.parse_document!(html)

    assert [_] =
             Floki.find(document, "pre.lumis-themes code.language-elixir .l-line[data-line='1']")

    assert document |> Floki.find("code") |> Floki.text() |> String.trim() == source
    assert html =~ "light-dark("
    assert html =~ "&lt;hello&gt;"
  end

  test "diff code blocks preserve the patch and highlight its tokens" do
    source = "@@ -1 +1 @@\n-old\n+new"
    html = MDExConverter.convert("example.md", "```diff\n#{source}\n```", %{}, [])
    document = Floki.parse_document!(html)
    code = Floki.find(document, "code.language-diff")

    lines = code |> Floki.find(".l-line") |> Enum.map(&Floki.text/1)

    assert lines == String.split(source, "\n")
    assert [_ | _] = Floki.find(code, "span[style]")
  end
end
