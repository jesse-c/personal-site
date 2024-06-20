defmodule PersonalSiteWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use PersonalSiteWeb, :controller
      use PersonalSiteWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: PersonalSiteWeb.Layouts]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {PersonalSiteWeb.Layouts, :app}

      # Start: Cursors

      alias PersonalSite.Cursors
      alias PersonalSite.Contributions
      alias PersonalSite.Notes
      alias PersonalSite.Projects
      alias PersonalSite.Works
      alias PersonalSiteWeb.Endpoint
      alias PersonalSiteWeb.Presence

      @impl true
      def mount(params, session, socket) do
        Endpoint.subscribe(Cursors.topic())

        # Do these common things for all LiveViews
        socket =
          socket
          |> assign(Presence.initialise(socket, self()))
          |> assign(notes: Notes.all_notes())
          |> assign(projects: Projects.all_projects())
          |> assign(works: Works.all_works())
          |> assign(contributions: Contributions.all_contributions())

        apply(__MODULE__, :inner_mount, [params, session, socket])
      end

      @impl true
      def handle_info(
            %Phoenix.Socket.Broadcast{
              topic: "cursors",
              event: "presence_diff",
              # Example:
              #
              # %{
              # joins: %{"123" => %{metas: [%{status: "away", phx_ref: ...}]}},
              # leaves: %{"456" => %{metas: [%{status: "online", phx_ref: ...}]}}
              # },
              payload: %{joins: joins, leaves: leaves} = payload
            },
            socket
          ),
          do: {:noreply, combine_presence_changes(socket, joins, leaves)}

      defp combine_presence_changes(socket, joins, leaves),
        do:
          socket
          |> combine_presence_leaves(leaves)
          |> combine_presence_joins(joins)

      defp combine_presence_joins(socket, joins),
        do:
          Enum.reduce(joins, socket, fn {user_joining, %{metas: [meta | _]}}, socket ->
            users = maybe_merge_users(socket, user_joining, meta)

            assign(socket, :users, users)
          end)

      defp maybe_merge_users(socket, user_joining, meta) do
        case Enum.find(socket.assigns.users, &(&1.socket_id == user_joining)) do
          nil ->
            [
              %{socket_id: user_joining, x: meta.x, y: meta.y, name: meta.name, hsl: meta.hsl}
              | socket.assigns.users
            ]

          user ->
            Enum.map(socket.assigns.users, fn
              %{socket_id: ^user_joining} ->
                %{user | x: meta.x, y: meta.y, name: meta.name, hsl: meta.hsl}

              other_user ->
                other_user
            end)
        end
      end

      defp combine_presence_leaves(socket, leaves),
        do:
          Enum.reduce(leaves, socket, fn {user_leaving, %{metas: [_ | _]}}, socket ->
            users =
              Enum.reject(socket.assigns.users, fn user -> user.socket_id == user_leaving end)

            assign(socket, :users, users)
          end)

      # Update the presence metadata for this user, by their key.
      #
      # Don't make any changes to the socket itself here.
      @impl true
      def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
        key = socket.id
        payload = %{x: x, y: y}

        metas =
          Presence.get_by_key(Cursors.topic(), key)[:metas]
          # Get the first item from the presence information, since I overwrite
          # the latest mouse position
          |> List.first()
          # Set the latest mouse position
          |> Map.merge(payload)

        Presence.update(self(), Cursors.topic(), key, metas)

        {:noreply, socket}
      end

      defoverridable mount: 3

      # End: Cursors

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import PersonalSiteWeb.CoreComponents

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PersonalSiteWeb.Endpoint,
        router: PersonalSiteWeb.Router,
        statics: PersonalSiteWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
