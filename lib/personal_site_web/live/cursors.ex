defmodule PersonalSiteWeb.Live.Cursors do
  @moduledoc """
  The cursors context.
  """

  use PersonalSiteWeb, :live_component

  alias PersonalSite.Cursors

  def render(assigns) do
    ~H"""
    <ul class="list-none z-50" id="cursors" phx-hook="TrackClientCursor">
      <li
        :for={user <- @users}
        style={"color: #{Cursors.get_hsl(user.name)}; left: #{user.x}%; top: #{user.y}%"}
        class="flex flex-col absolute pointer-events-none whitespace-nowrap overflow-hidden"
      >
        <svg
          version="1.1"
          width="25px"
          height="25px"
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          viewBox="0 0 21 21"
        >
          <circle cx="5" cy="5" r="5" fill="currentColor" />
        </svg>
        <span
          style={"background-color: #{Cursors.get_hsl(user.name)};"}
          class="mt-1 ml-4 px-1 text-sm text-white"
        >
          <%= user.name %>
        </span>
      </li>
    </ul>
    """
  end
end
