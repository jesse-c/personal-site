defmodule PersonalSite.MDExD2 do
  @moduledoc """
  MDEx codefence renderer for `d2` fenced code blocks. Renders d2
  source to inline SVG at compile time. Supports light/dark themes,
  percentage-width scaling, float layout, and optional borders.
  """

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
  Returns a codefence renderer function for the `"d2"` language
  identifier.

  Pass the result to MDEx's `codefence_renderers: %{"d2" =>
  renderer()}` option. Requires `render: [unsafe: true]` to allow the
  SVG HTML to pass through.
  """
  def renderer(opts \\ []) do
    theme = Keyword.get(opts, :d2_light_theme, @default_light_theme)
    dark_theme = Keyword.get(opts, :d2_dark_theme, @default_dark_theme)
    scale = Keyword.get(opts, :d2_scale, @default_scale_percentage)

    fn _lang, meta, code ->
      float = parse_float(meta)
      border = meta =~ "border"

      case render_d2(code, theme, dark_theme) do
        {:ok, svg} -> constrain(svg, scale, float, border)
        {:error, reason} -> raise "D2 render failed: #{reason}"
      end
    end
  end

  # Parse optional float options from the info string meta.
  @spec parse_float(String.t()) :: :left | :right | nil
  defp parse_float(meta) do
    cond do
      meta =~ "float=left" -> :left
      meta =~ "float=right" -> :right
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
