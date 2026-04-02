defmodule PersonalSite.MDExVl do
  @moduledoc """
  MDEx codefence renderer for `vl` fenced code blocks. Validates the
  Vega-Lite JSON spec at compile time, checks any local data file URLs
  exist on disk, and emits a `<div>` that the `VegaChart` LiveView hook
  renders at page load.
  """

  @doc """
  Returns a codefence renderer function for the `"vl"` language identifier.

  Pass the result to MDEx's `codefence_renderers: %{"vl" => renderer()}`
  option. Requires `render: [unsafe: true]` to allow the HTML to pass
  through.
  """
  def renderer do
    fn _lang, _meta, code ->
      # Validate JSON at compile time — raises on invalid syntax.
      spec = Jason.decode!(code)

      # Check any local data URLs exist on disk at compile time.
      spec
      |> extract_local_urls()
      |> Enum.each(&check_local_url_exists/1)

      # Re-encode normalised spec into a data attribute.
      #
      # Escape single quotes so the single-quoted HTML attribute is
      # never broken by apostrophes in spec string values (e.g. chart
      # titles).
      encoded = spec |> Jason.encode!() |> String.replace("'", "&#39;")
      id = :erlang.unique_integer([:positive])

      ~s(<div id="vega-#{id}" phx-hook="VegaChart" class="vega-chart" data-spec='#{encoded}'></div>)
    end
  end

  # Strip the leading "/" to get a relative path, then join with `priv/static`.
  defp check_local_url_exists(url) do
    relative = String.trim_leading(url, "/")
    path = Path.join([:code.priv_dir(:personal_site), "static", relative])

    unless File.exists?(path) do
      raise """
      vl chart references missing data file: #{url}
      Expected at: #{path}
      """
    end
  end

  # Recursively extract "url" values from "data" objects where the URL is
  # local (starts with "/"). External http(s) URLs are skipped.
  defp extract_local_urls(spec)

  # Map node: check for a local "data.url" at this level, then recurse into
  # all values to catch nested specs (e.g. layered or faceted charts).
  defp extract_local_urls(spec) when is_map(spec) do
    direct =
      case get_in(spec, ["data", "url"]) do
        url when is_binary(url) and binary_part(url, 0, 1) == "/" -> [url]
        _ -> []
      end

    children =
      spec
      |> Map.values()
      |> Enum.flat_map(&extract_local_urls/1)

    direct ++ children
  end

  # List node: recurse into each element to handle arrays of specs or transforms.
  defp extract_local_urls(list) when is_list(list) do
    Enum.flat_map(list, &extract_local_urls/1)
  end

  # Scalar (string, number, boolean, nil): nothing to extract.
  defp extract_local_urls(_), do: []
end
