defmodule PersonalSite.Shoutbox do
  use GenServer

  require Logger

  @topic "shoutbox"

  def topic, do: @topic

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def new(name, timestamp, message) do
    Logger.info("new")

    GenServer.call(__MODULE__, {:new, name, timestamp, message})
  end

  def list() do
    Logger.info("list")

    GenServer.call(__MODULE__, :list)
  end

  # Server (callbacks)

  @impl true
  def init(_opts) do
    # No shouts
    initial_state = []

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:new, name, timestamp, message}, _from, state) do
    Logger.info("new")

    shout = %{name: name, message: message, timestamp: timestamp}

    state = [shout | state]

    {:reply, :ok, state}
  end

  @doc """
  List all the current shouts
  """
  @impl true
  def handle_call(:list, _from, state) do
    Logger.info("list")

    {:reply, state, state}
  end
end
