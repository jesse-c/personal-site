defmodule PersonalSite.Plausible do
  @moduledoc """
  Plausible Analytics Events API client for tracking MCP endpoint usage.
  """

  require Logger

  @doc """
  Track a page view event to Plausible Analytics.

  This function is fire-and-forget - it runs asynchronously and won't block
  the request or cause failures if Plausible is unavailable.
  """
  def track_pageview(path, user_agent, ip_address, method \\ nil) do
    Task.start(fn ->
      Enum.each(
        get_site_domains(),
        &send_event("pageview", path, user_agent, ip_address, &1, method)
      )
    end)
  end

  defp send_event(name, path, user_agent, ip_address, domain, method) do
    config = Application.get_env(:personal_site, __MODULE__, [])
    enabled = Keyword.get(config, :enabled, false)

    if enabled do
      api_key = Keyword.get(config, :api_key, "")
      do_send_event(name, path, user_agent, ip_address, domain, api_key, method)
    end
  rescue
    error ->
      Logger.warning("Plausible tracking error: #{inspect(error)}")
  end

  defp do_send_event(name, path, user_agent, ip_address, domain, api_key, method) do
    if api_key == "" do
      Logger.error("Plausible tracking is enabled but PLAUSIBLE_API_KEY is not set")
      :ok
    else
      # Include method in path for better tracking (e.g., /mcp [GET], /mcp [POST])
      display_path = if method, do: "#{path} [#{method}]", else: path

      event_data = %{
        name: name,
        url: "https://#{domain}#{display_path}",
        domain: domain,
        props: %{
          endpoint: path,
          method: method
        }
      }

      headers = [
        {"Content-Type", "application/json"},
        {"User-Agent", user_agent || "MCP-Server/1.0"},
        {"X-Forwarded-For", format_ip(ip_address)},
        {"Authorization", "Bearer #{api_key}"}
      ]

      case Tesla.post(client(), "/api/event", event_data, headers: headers) do
        {:ok, %{status: status}} when status in 200..299 ->
          Logger.debug("Plausible event sent successfully: #{path}")

        {:ok, %{status: status, body: body}} ->
          Logger.warning("Plausible event failed with status #{status}: #{inspect(body)}")

        {:error, reason} ->
          Logger.warning("Failed to send Plausible event: #{inspect(reason)}")
      end
    end
  end

  @timeout_ms 5_000

  def middleware,
    do: [
      {Tesla.Middleware.BaseUrl, "https://plausible.io"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Timeout, timeout: @timeout_ms}
    ]

  def adapter,
    do: {Tesla.Adapter.Hackney, recv_timeout: @timeout_ms}

  def client, do: Tesla.client(middleware(), adapter())

  defp get_site_domains do
    host = System.get_env("PHX_HOST")
    host_alt = System.get_env("PHX_HOST_ALT")

    Enum.filter([host, host_alt], &(&1 != nil))
  end

  defp format_ip(ip_address)

  defp format_ip(ip_address) when is_tuple(ip_address) do
    ip_address |> :inet.ntoa() |> to_string()
  end

  defp format_ip(ip_address) when is_binary(ip_address), do: ip_address

  defp format_ip(_), do: "127.0.0.1"
end
