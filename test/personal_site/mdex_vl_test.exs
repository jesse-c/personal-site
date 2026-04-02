defmodule PersonalSite.MDExVlTest do
  use ExUnit.Case, async: true

  alias PersonalSite.MDExVl

  defp to_html(markdown) do
    MDEx.new(markdown: markdown)
    |> MDEx.to_html!(
      render: [unsafe: true],
      codefence_renderers: %{"vl" => MDExVl.renderer()}
    )
  end

  defp vl_block(json), do: "```vl\n#{json}\n```"

  @simple_spec ~s({"$schema":"https://vega.github.io/schema/vega-lite/v5.json","mark":"point"})

  describe "non-vl content" do
    test "passes through regular markdown unchanged" do
      html = to_html("# Hello\n\nWorld")
      assert html =~ "Hello"
      assert html =~ "World"
    end

    test "passes through non-vl code blocks unchanged" do
      html = to_html("```elixir\nIO.puts(\"hi\")\n```")
      assert html =~ "<code"
      refute html =~ "vega-chart"
    end
  end

  describe "vl code blocks" do
    test "renders a vl block as a div with the correct attributes" do
      html = to_html(vl_block(@simple_spec))
      assert html =~ ~r/id="vega-\d+"/
      assert html =~ ~s(phx-hook="VegaChart")
      assert html =~ ~s(class="vega-chart")
      assert html =~ "data-spec="
    end

    test "embeds the spec as JSON in the data-spec attribute" do
      html = to_html(vl_block(@simple_spec))
      assert html =~ ~s("mark":"point")
    end

    test "escapes single quotes in the spec" do
      spec = ~s({"title":"it's alive","mark":"point"})
      html = to_html(vl_block(spec))
      refute html =~ "it's"
      assert html =~ "it&#39;s"
    end

    test "renders multiple vl blocks in the same document" do
      spec_a = ~s({"mark":"point"})
      spec_b = ~s({"mark":"bar"})
      html = to_html("#{vl_block(spec_a)}\n\n#{vl_block(spec_b)}")
      assert html =~ ~s("mark":"point")
      assert html =~ ~s("mark":"bar")
      assert length(Regex.scan(~r/vega-chart/, html)) == 2
    end

    test "each block gets a unique id" do
      html = to_html("#{vl_block(@simple_spec)}\n\n#{vl_block(@simple_spec)}")
      ids = Regex.scan(~r/id="vega-(\d+)"/, html, capture: :all_but_first) |> List.flatten()
      assert length(ids) == 2
      assert Enum.uniq(ids) == ids
    end
  end

  describe "local data URL validation" do
    test "accepts a spec with no data URL" do
      html = to_html(vl_block(@simple_spec))
      assert html =~ "vega-chart"
    end

    test "accepts a spec with an external data URL" do
      spec = ~s({"data":{"url":"https://example.com/data.csv"},"mark":"point"})
      html = to_html(vl_block(spec))
      assert html =~ "vega-chart"
    end

    test "accepts a spec referencing an existing local file" do
      spec = ~s({"data":{"url":"/data/vega-example/training.csv"},"mark":"point"})
      html = to_html(vl_block(spec))
      assert html =~ "vega-chart"
    end

    test "raises when a local data URL points to a missing file" do
      spec = ~s({"data":{"url":"/data/does-not-exist.csv"},"mark":"point"})

      assert_raise RuntimeError, ~r/missing data file/, fn ->
        to_html(vl_block(spec))
      end
    end

    test "validates local URLs in nested layer specs" do
      spec = """
      {
        "layer": [
          {"data": {"url": "/data/does-not-exist.csv"}, "mark": "point"}
        ]
      }
      """

      assert_raise RuntimeError, ~r/missing data file/, fn ->
        to_html(vl_block(spec))
      end
    end
  end

  describe "invalid JSON" do
    test "raises on malformed JSON" do
      assert_raise Jason.DecodeError, fn ->
        to_html(vl_block("{not valid json}"))
      end
    end
  end
end
