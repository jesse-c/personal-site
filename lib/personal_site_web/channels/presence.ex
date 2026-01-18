defmodule PersonalSiteWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :personal_site,
    pubsub_server: PersonalSite.PubSub

  require Logger

  alias PersonalSite.Cursors

  def initialise(socket, pid) do
    Logger.debug("initialising presence")

    key = socket.id

    # Check if user already exists in presence
    {user, hsl} =
      case get_by_key(Cursors.topic(), key) do
        %{metas: [meta | _]} ->
          # Found existing user, keep their name and color
          {meta.name, meta.hsl}

        _ ->
          # New user, generate name and color
          name = MnemonicSlugs.generate_slug()

          {name, Cursors.get_hsl(name)}
      end

    # Track this presence
    track(
      pid,
      Cursors.topic(),
      key,
      %{
        x: nil,
        y: nil,
        name: user,
        socket_id: socket.id,
        hsl: hsl
      }
    )

    # Get the current list of users
    users = users()

    Logger.debug("initialised presence: user=#{user}")

    %{
      user: user,
      users: users
    }
  end

  def users do
    Cursors.topic()
    |> list()
    # Ignore the key, which was the cursors' topic
    |> Enum.map(fn {_, data} ->
      data
      |> Map.get(:metas)
      # Get the first item from the presence information, since I overwrite
      # the latest mouse position
      |> List.first()
    end)
  end

  def combine_presence_changes(users, joins, leaves),
    do:
      users
      |> combine_presence_leaves(leaves)
      |> combine_presence_joins(joins)

  defp combine_presence_joins(users, joins),
    do:
      Enum.reduce(joins, users, fn {user_joining, %{metas: [meta | _]}}, socket ->
        maybe_merge_users(socket, user_joining, meta)
      end)

  defp maybe_merge_users(users, user_joining, meta) do
    case Enum.find(users, &(&1.socket_id == user_joining)) do
      nil ->
        [
          %{socket_id: user_joining, x: meta.x, y: meta.y, name: meta.name, hsl: meta.hsl}
          | users
        ]

      user ->
        Enum.map(users, fn
          %{socket_id: ^user_joining} ->
            %{user | x: meta.x, y: meta.y, name: meta.name, hsl: meta.hsl}

          other_user ->
            other_user
        end)
    end
  end

  defp combine_presence_leaves(users, leaves),
    do:
      Enum.reduce(leaves, users, fn {user_leaving, %{metas: [_ | _]}}, _socket ->
        Enum.reject(users, fn user -> user.socket_id == user_leaving end)
      end)
end
