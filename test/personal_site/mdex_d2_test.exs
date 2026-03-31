defmodule PersonalSite.MDExD2Test do
  use ExUnit.Case, async: true

  alias PersonalSite.MDExD2

  @fixtures_dir Path.join([__DIR__, "..", "fixtures", "d2"])

  # D2 SVG output contains two path-dependent values that vary between renders:
  #   1. A CSS class hash derived from the output file path (e.g. "d2-2872498733")
  #   2. Embedded base64 WOFF font data (D2 subsets fonts per-render; the binary
  #      differs even for identical diagrams due to font toolchain internals)
  # Strip both before comparing so we assert on the actual diagram structure.
  defp normalise_svg(svg) do
    svg
    # Strip the constrain wrapper div so we compare diagram content only
    |> then(&Regex.replace(~r/<div style="[^"]+">/, &1, ""))
    |> then(&Regex.replace(~r/<\/div>\s*$/, &1, ""))
    # Normalise the inner SVG dimensions — either the constrained style or raw width/height attrs
    |> then(
      &Regex.replace(
        ~r/ style="width: 100%; height: auto;"/,
        &1,
        ~s( width="STRIPPED" height="STRIPPED")
      )
    )
    |> then(
      &Regex.replace(
        ~r/ width="\d+(?:\.\d+)?" height="\d+(?:\.\d+)?"/,
        &1,
        ~s( width="STRIPPED" height="STRIPPED")
      )
    )
    |> then(&Regex.replace(~r/d2-\d+/, &1, "d2-HASH"))
    |> then(
      &Regex.replace(~r/data-d2-version="v?\d+\.\d+\.\d+"/, &1, ~s(data-d2-version="STRIPPED"))
    )
    |> then(
      &Regex.replace(
        ~r/url\("data:application\/font-woff;base64,[^"]+"\)/,
        &1,
        "url(\"data:application/font-woff;base64,STRIPPED\")"
      )
    )
    # Trim last — after unwrapping the div, inner trailing newlines become visible
    |> String.trim_trailing()
  end

  defp fixture(name), do: File.read!(Path.join(@fixtures_dir, name))

  defp to_html(markdown, opts \\ []) do
    MDEx.new(markdown: markdown)
    |> MDEx.to_html!(
      render: [unsafe: true],
      codefence_renderers: %{"d2" => MDExD2.renderer(opts)}
    )
  end

  describe "non-d2 content" do
    test "passes through regular markdown unchanged" do
      html = to_html("# Hello\n\nWorld")
      assert html =~ "<h1>Hello</h1>"
      assert html =~ "World"
    end

    test "passes through non-d2 code blocks unchanged" do
      html = to_html("```elixir\nIO.puts(\"hi\")\n```")
      assert html =~ "<code"
      refute html =~ "<svg"
    end
  end

  describe "d2 code blocks" do
    test "renders a simple diagram to the expected SVG" do
      html = to_html("```d2\nx -> y\n```")
      assert normalise_svg(html) == normalise_svg(fixture("simple.svg"))
    end

    test "renders multiple diagrams in the same document" do
      html = to_html("```d2\na -> b\n```\n\nSome text\n\n```d2\nc -> d\n```")
      assert normalise_svg(html) =~ normalise_svg(fixture("diagram_a.svg"))
      assert normalise_svg(html) =~ normalise_svg(fixture("diagram_b.svg"))
    end

    test "includes dark mode media query in output" do
      html = to_html("```d2\nx -> y\n```")
      assert html =~ "prefers-color-scheme"
    end

    test "renders diagram alongside regular markdown" do
      html = to_html("# Title\n\n```d2\nx -> y\n```\n\nFooter")
      assert html =~ "<h1>Title</h1>"
      assert normalise_svg(html) =~ normalise_svg(fixture("simple.svg"))
      assert html =~ "Footer"
    end
  end

  describe "error handling" do
    test "raises on invalid d2 syntax" do
      assert_raise RuntimeError, ~r/D2 render failed/, fn ->
        to_html("```d2\n->->->\n```")
      end
    end
  end
end
