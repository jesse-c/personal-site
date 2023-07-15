defmodule PersonalSiteWeb.Live.Education do
  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Education")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
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
    """
  end
end
