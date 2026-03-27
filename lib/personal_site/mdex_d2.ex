defmodule PersonalSite.MDExD2 do
  @moduledoc """
  MDEx pipeline plugin that renders `d2` fenced code blocks to inline SVG at
  compile time. Supports light/dark themes, percentage-width scaling, float
  layout, and optional borders.
  """

  alias MDEx.Document

  # Themes
  #
  # Light:
  #
  # #1. Neutral Grey
  @default_light_theme 1
  # Dark:
  #
  # #201. Dark Flagship Terrastruct
  @default_dark_theme 201

  # Render the diagram at this percentage of the container width,
  # centred.
  @default_scale_percentage 65

  @doc """
  Attach the D2 pipeline plugin to an `MDEx` document.
  """
  def attach(document, opts \\ []) do
    document
    |> Document.register_options([:d2_light_theme, :d2_dark_theme, :d2_scale])
    |> Document.put_options(opts)
    |> Document.append_steps(enable_unsafe: &enable_unsafe/1)
    |> Document.append_steps(render_d2_blocks: &render_d2_blocks/1)
  end

  # Enable the render options needed to inject raw SVG into the
  # document.
  defp enable_unsafe(document) do
    document
    |> Document.put_render_options(
      # Allow `HtmlBlock` nodes to render as raw HTML
      unsafe: true,
      # Override any caller-set escape: true that would escape our SVG
      escape: false
    )
    # `tagfilter` strips `<style>` tags, which breaks
    # D2's embedded CSS.
    |> Document.put_extension_options(tagfilter: false)
  end

  # Replace every `d2` fenced code block in the document with a
  # rendered SVG wrapped in a sizing/layout `div`. Info string options
  # are parsed from each node's info string.
  defp render_d2_blocks(document) do
    theme = Document.get_option(document, :d2_light_theme, @default_light_theme)
    dark_theme = Document.get_option(document, :d2_dark_theme, @default_dark_theme)
    scale = Document.get_option(document, :d2_scale, @default_scale_percentage)

    # Walk every node in the document AST, looking for D2 nodes
    Document.update_nodes(
      document,
      fn
        # Selects nodes to transform
        %MDEx.CodeBlock{info: "d2" <> _} -> true
        _ -> false
      end,
      # Replaces each selected node with a new one
      fn node ->
        float = parse_float(node.info)
        border = node.info =~ "border"

        # Replace `d2` code blocks with HTML, raising on failure so that
        # invalid diagrams are caught at compile time rather than silently
        # rendering an error in the page.
        case render_d2(node.literal, theme, dark_theme) do
          {:ok, svg} -> %MDEx.HtmlBlock{literal: constrain(svg, scale, float, border)}
          {:error, reason} -> raise "D2 render failed: #{reason}"
        end
      end
    )
  end

  # Parse optional float options
  @spec parse_float(String.t()) :: :left | :right | nil
  defp parse_float(info) do
    cond do
      info =~ "float=left" -> :left
      info =~ "float=right" -> :right
      true -> nil
    end
  end

  # Wrap the SVG in a percentage-width container and make it fill that container
  # by stripping D2's fixed width/height attrs.
  #
  # Apply floating as well, if present.
  defp constrain(svg, scale, float, border) do
    # D2 emits fixed pixel `width` and `height` attrs on the `<svg>` opening
    # tag (e.g. `<svg … width="320" height="240">`). Strip both so the SVG
    # scales to fill its container, while `viewBox` (kept intact) preserves
    # the aspect ratio.
    #
    # Pattern:
    #   (<svg\b[^>]*?)   capture `<svg` up to the first `width`; `\b` prevents
    #                    matching `<svg-foo`; `[^>]*?` non-greedy so it stops
    #                    at the first `width` found rather than the last `>`
    #   width="…"        literal attr with optional decimal (e.g. "320.5")
    #   height="…"       same, immediately following `width`
    responsive_svg =
      Regex.replace(
        ~r/(<svg\b[^>]*?) width="\d+(?:\.\d+)?" height="\d+(?:\.\d+)?"/,
        svg,
        ~s(\\1 style="width: 100%; height: auto;")
      )

    layout =
      case float do
        :left -> "float: left; width: #{scale}%; margin: 0 2em 1em 0;"
        :right -> "float: right; width: #{scale}%; margin: 0 0 1em 2em;"
        nil -> "width: #{scale}%; margin: 0 auto 1em;"
      end

    border_style =
      if border,
        do: " border: 1px solid currentColor; border-radius: 4px; overflow: hidden;",
        else: ""

    ~s(<div style="#{layout}#{border_style}">#{responsive_svg}</div>)
  end

  # Render D2 source to SVG by writing it to a temp file, invoking the `d2`
  # CLI, and reading the output.
  #
  # Temp files are always cleaned up.
  defp render_d2(source, theme, dark_theme) do
    # Get a unique ID for this diagram
    id = :erlang.unique_integer([:positive])

    tmp = System.tmp_dir!()

    input = Path.join(tmp, "d2_#{id}.d2")
    output = Path.join(tmp, "d2_#{id}.svg")

    try do
      File.write!(input, source)

      case System.cmd(
             "d2",
             ["--theme", to_string(theme), "--dark-theme", to_string(dark_theme), input, output],
             stderr_to_stdout: true
           ) do
        # `System.cmd` returns `{output, exit_code}`.
        #
        # Exit code 0 means success.
        {_, 0} -> {:ok, File.read!(output)}
        # Any non-zero exit code is a failure; `err` is the captured stderr output.
        {err, _} -> {:error, err}
      end
    after
      File.rm(input)
      File.rm(output)
    end
  end
end
