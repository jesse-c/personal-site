defmodule PersonalSiteWeb.Live.ShoutboxIndex do
  @moduledoc """
  The app page for the Shoutbox.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Shoutbox
  alias PersonalSiteWeb.Live.Cursors

  require Logger

  def inner_mount(_params, _session, socket) do
    Endpoint.subscribe(Shoutbox.topic())
    Endpoint.subscribe(Shoutbox.connection_topic())

    shouts = Shoutbox.list()

    {
      :ok,
      socket
      |> assign(page_title: "Shoutbox")
      |> assign(shouts_by_date: group_shouts_by_date(shouts))
      |> assign(redis_connected?: Shoutbox.connected?())
    }
  end

  defp group_shouts_by_date(shouts) do
    shouts
    |> Enum.group_by(& &1.timestamp.year)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.map(fn {year, year_shouts} ->
      months =
        year_shouts
        |> Enum.group_by(& &1.timestamp.month)
        |> Enum.sort_by(&elem(&1, 0), :desc)
        |> Enum.map(fn {month, month_shouts} ->
          days =
            month_shouts
            |> Enum.group_by(& &1.timestamp.day)
            |> Enum.sort_by(&elem(&1, 0), :desc)

          {month, days}
        end)

      {year, months}
    end)
  end

  def handle_info(%{topic: "shoutbox", event: "save"}, socket) do
    shouts = Shoutbox.list()
    {:noreply, assign(socket, shouts_by_date: group_shouts_by_date(shouts))}
  end

  def handle_info({:connection_status, connected?}, socket) do
    {:noreply, assign(socket, redis_connected?: connected?)}
  end

  # Use an arbitrary year and day
  defp month_name(month_num), do: Calendar.strftime(Date.new!(2021, month_num, 1), "%B")

  defp format_time(timestamp) do
    Calendar.strftime(timestamp, "%H:%M")
  end

  def render(assigns) do
    ~H"""
    <.live_component module={Cursors} id="cursors" users={@users} />
    <div class="flex items-center gap-2">
      <h1 class="text-lg">Shoutbox</h1>
      <span
        class={"database-status #{if @redis_connected?, do: "connected", else: "disconnected"}"}
        data-tooltip={
          if @redis_connected?, do: "Connected to database", else: "Disconnected from database"
        }
        aria-label={
          if @redis_connected?, do: "Connected to database", else: "Disconnected from database"
        }
      >
      </span>
    </div>
    <div class="space-y-3 mt-3">
      <div :for={{year, months} <- @shouts_by_date} class="space-y-1">
        <div><strong>{year}</strong></div>
        <div class="space-y-3">
          <div :for={{month, days} <- months} class="space-y-1">
            <div>{month_name(month)}</div>
            <div :for={{day, shouts} <- days} class="space-y-1">
              <div class="text-sm">{day}</div>
              <div :for={shout <- shouts} class="space-y-1">
                <p class="text-sm">
                  <span class="text-xs">{format_time(shout.timestamp)}</span>
                  <strong>{shout.name}:</strong> {shout.message}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
