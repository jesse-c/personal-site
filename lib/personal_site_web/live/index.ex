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
    <div>
      <h2>Hello,</h2>
      <p>I’m a software engineer&mdash;and sometimes a photographer or designer.</p>
      <p><.link navigate={~p"/about"}>More →</.link></p>
    </div>
    <div>
      <h2>Notes</h2>
      <div :for={note <- Enum.take(@notes, 5)}>
        <%= note.title %>
        <%= note.date %>
        <%= Enum.join(note.tags, ", ") %>
      </div>
      <p><.link navigate={~p"/notes"}>Index <%= Enum.count(@notes) %> →</.link></p>
    </div>
    <div>
      <h2>Works</h2>
      <div :for={work <- Enum.take(@works, 2)}>
        <%= work.title %>
        <%= work.date_start %>
        <%= work.date_end %>
        <%= work.description %>
      </div>
      <p><.link navigate={~p"/works"}>Index <%= Enum.count(@works) %> →</.link></p>
    </div>
    <div>
      <h2>Projects</h2>
      <div :for={project <- @projects |> Enum.shuffle |> Enum.take(2)}>
        <%= project.title %>
        <%= project.description %>
        <%= Enum.join(project.tags, ", ") %>
      </div>
      <p><.link navigate={~p"/projects"}>Index <%= Enum.count(@projects) %> →</.link></p>
    </div>
    <div>
      <h2>Education</h2>
      <h3>Bachelor of Engineering &mdash; Software (Honours) at University of Queensland</h3>
      <h4>Thesis (Undergraduate)</h4>
      <p>Technology-supported activities through realtime, distributed, and collaborative interfaces</p>
      <p>Abstract</p>
      <p>Traditionally user interfaces have been designed for a single user using one common device type&mdash;e.g. someone on a computer visiting a website. With the internet and mobile devices now being commonplace, interfaces could take advantage of being distributed across devices and working collaboratively with others in real-time. While there have been attempts to to handle this (e.g. Google Docs), they have so far been in a limited, prescribed manner. A proposed concept is put forward to design and build a new approach for a distributed and real-time collaborative user interface focusing on the concept of having a workspace with components that the user is able to freely use in a real-time manner. It is based upon existing web browsers and devices. Parts of the UI can be distributed across separate platforms. A prototype of a workspace for education is included and user testing of the prototype shows positive experiences and results for the users.</p>
      <p><a href="https://github.com/jesse-c/thesis" target="_blank">Full thesis ↗</a></p>
      <p><a href="https://github.com/jesse-c/thesis-workspace" target="_blank">Prototype ↗</a></p>
    </div>
    <div>
      <h2>Get in touch</h2>
      <p>I’m available through <a rel="me" href="https://mastodon.social/@jqk">Mastodon ↗</a> for mixed chat and <a href="https://github.com/jesse-c" target="_blank">GitHub ↗</a> for various projects/contributions and collaboration.</p>
    </div>
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
