defmodule PersonalSiteWeb.Live.Index do
  @moduledoc """
  The homepage.
  """

  use PersonalSiteWeb, :live_view

  alias PersonalSite.Shoutbox
  alias PersonalSiteWeb.Live.Cursors

  require Logger

  def inner_mount(_params, _session, socket) do
    Endpoint.subscribe(Shoutbox.topic())
    Endpoint.subscribe(Shoutbox.connection_topic())

    socket =
      socket
      |> assign(form: to_form(%{"message" => nil}))
      |> assign(shouts: Shoutbox.list())
      |> assign(
        shouts_max_display:
          Application.get_env(:personal_site, PersonalSite.Shoutbox)[:max_display]
      )
      |> assign(redis_connected?: Shoutbox.connected?())
      |> assign(page_title: "Home")

    {:ok, socket}
  end

  def handle_event("validate", %{"message" => message} = _params, socket) do
    socket = assign(socket, form: to_form(%{"message" => message}))
    {:noreply, socket}
  end

  def handle_event("validate", params, socket) do
    Logger.warning("malformed validate params: #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event("save", %{"message" => message}, socket) do
    if match?(
         {:deny, _ms_until_next_window},
         PersonalSite.RateLimit.hit("save:#{socket.assigns[:client_ip]}", :timer.minutes(10), 10)
       ) do
      socket =
        socket
        |> clear_flash()
        |> put_flash(:error, "Try again later!")

      {:noreply, socket}
    else
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

  def handle_info({:connection_status, connected?}, socket) do
    {:noreply, assign(socket, redis_connected?: connected?)}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={Cursors} id="cursors" users={@users} />
    <div class="flex flex-col md:flex-row md:gap-4 mb-6">
      <div class="border border-dashed rounded-sm border-black dark:border-white p-2 mb-2 md:mb-0 text-xs max-w-fit">
        Remember to try the <a href="#shoutbox">shoutbox</a>! &#8595
      </div>
      <div class="border border-dashed rounded-sm border-black dark:border-white p-2 text-xs max-w-fit">
        See each others' cursors! &#9758;
      </div>
    </div>
    <div class="flex flex-col md:flex-row">
      <div class="space-y-10 md:w-1/2 md:max-w-1/2">
        <div class="space-y-3">
          <h2 class="text-lg">Hello,</h2>
          <p class="text-sm">
            I’m a software and ML engineer—and sometimes a photographer or designer.
          </p>
          <div>
            <.link class="text-xs" navigate={~p"/about"}>More →</.link>
          </div>
        </div>
        <div class="space-y-3">
          <h2 class="text-lg">Blog</h2>
          <div class="space-y-3">
            <div :for={post <- Enum.take(@posts, 5)} class="space-y-1">
              <p class="text-sm">
                <.link navigate={~p"/blog/#{post.slug}"}>
                  {post.title}
                </.link>
              </p>
              <p class="text-xs">
                {post.date_created}
                <%= if post.date_updated do %>
                  (updated: {post.date_updated})
                <% end %>
                ･ <PersonalSiteWeb.TagsComponents.inline tags={post.tags} />
              </p>
            </div>
          </div>
          <div>
            <.link class="text-xs" navigate={~p"/blog"}>
              Index<span class="sup pl-0.5"><%= Enum.count(@posts) %></span> →
            </.link>
          </div>
        </div>
      </div>
      <div class="space-y-10 md:w-1/2 mt-10 md:mt-0">
        <div class="space-y-3">
          <div class="flex items-center gap-2">
            <h2 id="shoutbox" class="text-lg">Shoutbox</h2>
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
          <h3 class="text-sm">
            Latest<span class="sup pl-0.5"><%= min(Enum.count(@shouts), @shouts_max_display) %> of <%= Enum.count(@shouts) %></span>
          </h3>
          <%= if Enum.empty?(@shouts) do %>
            <div>
              <p class="text-xs">None yet</p>
            </div>
          <% else %>
            <div class="space-y-3">
              <div :for={shout <- Enum.take(@shouts, @shouts_max_display)} class="space-y-1">
                <p class="text-xs">
                  &#9786; {shout.name} ･ &#9200; {Timex.from_now(shout.timestamp)}
                </p>
                <p class="text-xs">{shout.message}</p>
              </div>
            </div>
          <% end %>
          <div class="space-y-3">
            <.link class="text-xs" navigate={~p"/apps/shoutbox"}>
              View all<span class="sup pl-0.5"><%= Enum.count(@shouts) %></span> →
            </.link>
          </div>
          <div class="space-y-3">
            <h3 class="text-sm">New</h3>
            <.form class="space-y-3" for={@form} phx-change="validate" phx-submit="save">
              <div class="md:w-96">
                <.input
                  type="text"
                  field={@form[:message]}
                  maxlength="255"
                  disabled={!@redis_connected?}
                />
              </div>
              <div>
                <button
                  disabled={
                    !@redis_connected? or is_nil(@form[:message].value) or @form[:message].value == ""
                  }
                  class="border border-solid rounded-sm border-black dark:border-white hover:bg-black dark:hover:bg-white text-black dark:text-white hover:text-white dark:hover:text-black transition-colors py-1 px-1 mb-6 text-xs max-w-fit disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Save
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
