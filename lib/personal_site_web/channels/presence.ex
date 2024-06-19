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

    user = MnemonicSlugs.generate_slug()
    hsl = Cursors.get_hsl(user)

    # Track this new presence, so that it's apart of the overall
    # list of users' presences.
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

    Logger.debug("initialised presence")

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
end
