defmodule PersonalSite.Shoutbox do
  @moduledoc """
  A shoutbox in the spirit of the early 2000s.
  """

  use GenServer

  require Logger

  @topic "shoutbox"

  alias PersonalSite.Redis

  def topic, do: @topic

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Takes a new shout
  """
  def new(name, timestamp, message) do
    GenServer.call(__MODULE__, {:new, name, timestamp, message})
  end

  @doc """
  List all the current shouts
  """
  def list() do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Clear all the current shouts
  """
  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  # Server (callbacks)

  @impl true
  def init(_opts) do
    # No shouts
    initial_state = []

    {:ok, initial_state, {:continue, {:load, 0}}}
  end

  @impl true
  def handle_continue({:load, attempt_n}, state) do
    Logger.debug("load attempt: #{attempt_n}")

    if attempt_n < Application.get_env(:personal_site, PersonalSite.Redis)[:connection_attempts] do
      case Redis.command(["LRANGE", "shouts", 0, -1]) do
        {:ok, value} ->
          value = raw_value_to_shout(value)

          Logger.debug("loaded shouts: #{Enum.count(value)}")

          :ok = trim_by_state(state)

          value =
            Enum.take(value, Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max])

          {:noreply, value}

        {:error, error} ->
          Logger.debug("failed to load shouts: #{inspect(error)}")

          {:noreply, state, {:continue, {:load, attempt_n + 1}}}
      end
    else
      Logger.debug("load attempt threshold reached")

      {:noreply, state}
    end
  end

  defp raw_value_to_shout(value),
    do:
      value
      |> Enum.map(&Jason.decode!(&1, keys: :atoms))
      |> Enum.map(fn shout ->
        # Parse the string as a timestamp
        {:ok, timestamp, _calendar_offset} = DateTime.from_iso8601(shout.timestamp)

        %{shout | timestamp: timestamp}
      end)

  defp trim_by_state(state) do
    if Enum.count(state) >=
         Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max] do
      Logger.debug(
        "trimming shouts: #{Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max]}"
      )

      trim()
    else
      Logger.debug(
        "shouts trimming not needed: #{Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max]}"
      )
    end

    :ok
  end

  @impl true
  def handle_call({:new, name, timestamp, message}, _from, state) do
    state =
      if Enum.count(state) >=
           Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max] do
        Logger.debug("hit limit: #{Enum.count(state)}")

        trim()

        # Take the max
        Enum.take(state, Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max] - 1)
      else
        Logger.debug("didn't hit limit: #{Enum.count(state)}")

        state
      end

    message = message |> String.trim() |> String.slice(0..255)

    message_length = String.length(message)

    Logger.debug("message length: #{message_length}")

    if message_length == 0 do
      Logger.debug("empty message")

      {:reply, :ok, state}
    else
      shout = %{name: name, message: message, timestamp: timestamp}

      with {:ok, shout_json} <- Jason.encode(shout),
           command = ["LPUSH", "shouts", shout_json],
           {:ok, _new_list_length} <- Redis.command(command) do
        Logger.debug("stored in Redis")
      else
        {:error, error} ->
          Logger.debug("failed to store in Redis: #{inspect(error)}")

        unexpected ->
          Logger.debug("failed to store in Redis: #{inspect(unexpected)}")
      end

      state = [shout | state]

      notify(shout)

      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:clear, _from, _state) do
    state = []

    case Redis.command(["DEL", "shouts"]) do
      {:ok, _list_length_deleted} ->
        Logger.debug("cleared shouts")

      {:error, error} ->
        Logger.debug("failed to clear shouts in Redis: #{inspect(error)}")
    end

    {:reply, :ok, state}
  end

  defp trim do
    case Redis.command([
           "LTRIM",
           "shouts",
           0,
           # - 1 since it's 0-index
           Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max] - 1
         ]) do
      {:ok, _simple_string} ->
        Logger.debug("trimmed shouts")

      {:error, error} ->
        Logger.debug("failed to trim shouts: #{inspect(error)}")
    end
  end

  defp notify(shout) do
    message =
      "shout sent from #{shout.name} at #{DateTime.to_iso8601(shout.timestamp)}: #{shout.message}"

    Logger.debug(message)

    if Application.get_env(:personal_site, PersonalSiteWeb.Pushover)[:enabled] do
      api_key = Application.get_env(:personal_site, PersonalSiteWeb.Pushover)[:api_key]
      user_key = Application.get_env(:personal_site, PersonalSiteWeb.Pushover)[:user_key]

      Req.post!(
        "https://api.pushover.net/1/messages.json",
        json: %{
          token: api_key,
          user: user_key,
          message: message
        }
      )
    end
  end
end
