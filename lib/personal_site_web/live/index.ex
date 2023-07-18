defmodule PersonalSiteWeb.Live.Index do
  use PersonalSiteWeb, :live_view

  alias PersonalSite.Shoutbox
  alias PersonalSite.Works.Work

  require Logger

  def inner_mount(_params, _session, socket) do
    Endpoint.subscribe(Shoutbox.topic())

    socket =
      socket
      |> assign(form: to_form(%{"message" => nil}))
      |> assign(shouts: Shoutbox.list())
      |> assign(page_title: "Home")

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

    :ok =
      Endpoint.broadcast(Shoutbox.topic(), "save", %{
        name: name,
        message: message,
        timestamp: timestamp
      })

    socket =
      socket
      |> put_flash(:info, "Shout sent!")
      # Reset the form
      |> assign(form: to_form(%{"message" => nil}))

    Process.send_after(
      self(),
      :clear_flash,
      Application.get_env(:personal_site, PersonalSite.Shoutbox)[:clear]
    )

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
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
          else: put_flash(socket, :info, "Someone sent a shout!")
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <div class="border border-dashed rounded-sm border-black dark:border-white p-2 mb-6 text-xs max-w-fit">
      &#9788; Remember to try the shoutbox! &#8595
    </div>
    <div class="space-y-10">
      <div class="space-y-3">
        <h2 class="text-lg">Hello,</h2>
        <p class="text-sm">
          I’m a ⍚ software engineer—and sometimes a ⛰ photographer or ♤ designer.
        </p>
        <div>
          <.link class="text-xs" navigate={~p"/about"}>More →</.link>
        </div>
      </div>
      <div class="space-y-3">
        <h2 class="text-lg">Notes</h2>
        <div class="space-y-3">
          <div :for={note <- Enum.take(@notes, 5)} class="space-y-1">
            <p class="text-sm">
              <.link navigate={~p"/notes/#{note.slug}"}>
                <%= note.title %>
              </.link>
            </p>
            <p class="text-xs"><%= note.date %> ･ <%= Enum.join(note.tags, ", ") %></p>
          </div>
        </div>
        <div>
          <.link class="text-xs" navigate={~p"/notes"}>
            Index<span class="sup pl-0.5"><%= Enum.count(@notes) %></span> →
          </.link>
        </div>
      </div>
      <div class="space-y-3">
        <h2 class="text-lg">Works</h2>
        <div class="space-y-3">
          <div :for={work <- Enum.take(@works, 5)} class="space-y-1">
            <p class="text-sm"><%= work.title %></p>
            <p class="text-xs"><%= work.role %></p>
            <p class="text-xs"><%= Work.date(work.date_start) %> — <%= Work.date(work.date_end) %></p>
            <p class="text-xs"><%= work.description %></p>
            <p class="text-xs"><%= Enum.join(work.tags, ", ") %></p>
          </div>
        </div>
        <div>
          <.link class="text-xs" navigate={~p"/works"}>
            Index<span class="sup pl-0.5"><%= Enum.count(@works) %></span> →
          </.link>
        </div>
      </div>
      <div class="space-y-3">
        <h2 class="text-lg">Projects</h2>
        <div class="space-y-3">
          <div :for={project <- Enum.take(@projects, 5)} class="space-y-1">
            <p class="text-sm"><%= project.title %></p>
            <p class="text-xs"><%= project.description %></p>
            <p class="text-xs"><%= Enum.join(project.tags, ", ") %></p>
          </div>
        </div>
        <div>
          <.link class="text-xs" navigate={~p"/projects"}>
            Index<span class="sup pl-0.5"><%= Enum.count(@projects) %></span> →
          </.link>
        </div>
      </div>
      <div class="space-y-3">
        <h2 class="text-lg">Education</h2>
        <h3 class="text-base">
          Bachelor of Engineering — Software (Honours) at University of Queensland
        </h3>
        <h4 class="text-sm font-bold">Thesis (Undergraduate)</h4>
        <p class="text-sm">
          Technology-supported activities through realtime, distributed, and collaborative interfaces
        </p>
        <p class="text-sm">Abstract</p>
        <p class="text-xs">
          Traditionally user interfaces have been designed for a single user using one common device type—e.g. someone on a computer visiting a website. With the internet and mobile devices now being commonplace, interfaces could take advantage of being distributed across devices and working collaboratively with others in real-time. While there have been attempts to to handle this (e.g. Google Docs), they have so far been in a limited, prescribed manner. A proposed concept is put forward to design and build a new approach for a distributed and real-time collaborative user interface focusing on the concept of having a workspace with components that the user is able to freely use in a real-time manner. It is based upon existing web browsers and devices. Parts of the UI can be distributed across separate platforms. A prototype of a workspace for education is included and user testing of the prototype shows positive experiences and results for the users.
        </p>
        <p class="text-xs">
          <a href="https://github.com/jesse-c/thesis" target="_blank">
            Full thesis ↗
          </a>
        </p>
        <p class="text-xs">
          <a href="https://github.com/jesse-c/thesis-workspace" target="_blank">
            Prototype ↗
          </a>
        </p>
      </div>
      <div class="space-y-3">
        <h2 class="text-lg">Contact</h2>
        <p class="text-sm">
          I’m available through <a rel="me" href="https://mastodon.social/@jqk">Mastodon ↗</a>
          for mixed chat and <a href="https://github.com/jesse-c" target="_blank">GitHub ↗</a>
          for various projects/contributions and collaboration.
        </p>
      </div>
      <div class="space-y-3">
        <h2 class="text-lg">Shoutbox</h2>
        <h3 class="text-sm">
          Latest<span class="sup pl-0.5"><%= min(Enum.count(@shouts), 10) %> of <%= Enum.count(@shouts) %></span>
        </h3>
        <div class="space-y-3">
          <div :for={shout <- Enum.take(@shouts, 10)} class="space-y-1">
            <p class="text-sm">
              &#9786; <%= shout.name %> ･ &#9200; <%= Timex.from_now(shout.timestamp) %>
            </p>
            <p class="text-sm"><%= shout.message %></p>
          </div>
        </div>
        <div class="space-y-3">
          <h3 class="text-sm">New</h3>
          <.form class="space-y-3" for={@form} phx-change="validate" phx-submit="save">
            <div class="md:w-96">
              <.input type="text" field={@form[:message]} maxlength="255" />
            </div>
            <div>
              <button class="border border-solid rounded-sm border-black dark:border-white hover:bg-black dark:hover:bg-white text-black dark:text-white hover:text-white dark:hover:text-black transition-colors p-2 mb-6 text-xs max-w-fit">
                Save
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
