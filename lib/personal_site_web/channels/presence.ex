defmodule PersonalSiteWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :personal_site,
    pubsub_server: PersonalSite.PubSub

  alias PersonalSite.Cursors

  def initialise(socket, pid) do
    user = MnemonicSlugs.generate_slug()
    hsl = Cursors.get_hsl(user)

    track(
      pid,
      Cursors.topic(),
      socket.id,
      %{
        x: nil,
        y: nil,
        name: user,
        socket_id: socket.id,
        hsl: hsl
      }
    )

    initial_users = users()

    %{
      x: nil,
      y: nil,
      user: user,
      socket_id: socket.id,
      users: initial_users,
      hsl: hsl
    }
  end

  def users do
    Cursors.topic()
    |> list()
    |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)
  end
end
