defmodule PersonalSiteWeb.Live.About do
  @moduledoc """
  The about context page.
  """

  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    socket = assign(socket, page_title: "About")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <h1 class="text-lg">About</h1>
    <div class="space-y-3">
      <p class="text-sm">
        I'm a multi-disciplinary software engineer, with design experience, in back- and front-end, iOS, prototyping, machine learning, user testing, etc.
      </p>
      <p class="text-sm">
        I've worked at Experience at large international companies, to new startups.
      </p>
      <p class="text-sm">
        I've made several minor contributions to open source software and released small packages and applications, along with being involved in open source communities. I've involved in volunteer and community work locally and internationally.
      </p>
    </div>
    """
  end
end
