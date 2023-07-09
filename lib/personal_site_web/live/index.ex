defmodule PersonalSiteWeb.Live.Index do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Shoutbox

  require Logger

  def inner_mount(_params, _session, socket) do
    Endpoint.subscribe(Shoutbox.topic())

    socket =
      socket
      |> assign(form: to_form(%{"message" => nil}))
      |> assign(shouts: Shoutbox.list())

    {:ok, socket}
  end

  def handle_event("validate", %{"message" => message}, socket) do
    socket = assign(socket, form: to_form(%{"message" => message}))

    {:noreply, socket}
  end

  def handle_event("save", %{"message" => message}, socket) do
    timestamp = DateTime.utc_now()

    name = socket.assigns[:user]

    :ok = Shoutbox.new(name, timestamp, message)

    Endpoint.broadcast(Shoutbox.topic(), "save", %{
      name: name,
      message: message,
      timestamp: timestamp
    })

    socket =
      socket
      |> put_flash(:info, "shout save")
      # Rest the form
      |> assign(form: to_form(%{"message" => nil}))

    {:noreply, socket}
  end

  def handle_info(
        %{
          topic: "shoutbox",
          event: "save",
          payload: %{message: _message, name: name, timestamp: _timestamp}
        },
        socket
      ) do
    socket =
      socket
      |> assign(shouts: Shoutbox.list())
      # Conditionally notify other users
      |> then(fn socket ->
        if socket.assigns[:user] == name,
          do: socket,
          else: put_flash(socket, :info, "someone shouted")
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1>Index</h1>
    <div>
      <h2>Shouts (<%= Enum.count(@shouts) %>)</h2>
      <div :for={shout <- Enum.take(@shouts, 10)}>
        <%= shout.name %>
        <%= shout.timestamp %>
        <%= shout.message %>
      </div>
    </div>
    <div>
    <.form for={@form} phx-change="validate" phx-submit="save">
      <.input type="text" field={@form[:message]} />
      <button>Save</button>
    </.form>
    </div>
    """
  end
end
