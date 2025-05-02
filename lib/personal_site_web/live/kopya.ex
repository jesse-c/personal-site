defmodule PersonalSiteWeb.Live.Kopya do
  @moduledoc """
  The app page for Kopya.
  """

  use PersonalSiteWeb, :live_view

  def inner_mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <div class="fixed right-2 mt-2 border border-gray-200 rounded text-black dark:text-white bg-white dark:bg-black p-4 text-sm z-10">
      <h2 class="font-bold">Table of Contents</h2>
      <ol class="mt-2 list-decimal">
        <li><a href="#introduction">Introduction</a></li>
        <li><a href="#integrations">Integrations</a></li>
        <li><a href="#features">Features</a></li>
        <li><a href="#roadmap">Roadmap</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#motivation">Motivation</a></li>
      </ol>
    </div>

    <div
      id="container"
      class="md:w-3/4 md:max-w-3/4 flex flex-col divide-y divide-slate-200 border-x border-slate-200 mx-auto border-b"
    >
      <div id="introduction" class="p-4 text-center space-y-2">
        <div class="flex items-center justify-center gap-2">
          <h1 class="text-2xl">Kopya</h1>
          <span class="bg-black dark:bg-white text-white dark:text-black text-xs rounded py-px px-0.5">
            Alpha
          </span>
        </div>
        <p>
          Kopya is a clipboard history <em>engine</em>. You then use it where ever you can do a network request.
        </p>
      </div>

      <div id="integrations" class="p-4">
        <h2 class="text-xl font-bold mb-4">Integrations</h2>
        <div class="overflow-x-auto">
          <table class="min-w-full bg-white dark:bg-black border border-gray-300 text-sm">
            <thead>
              <tr class="bg-black dark:bg-white text-white dark:text-black">
                <th class="px-4 py-2 text-left">Name</th>
                <th class="px-4 py-2 text-left">Status</th>
                <th class="px-4 py-2 text-left">Link</th>
              </tr>
            </thead>
            <tbody>
              <tr class="border-b border-gray-300">
                <td class="px-4 py-2">Raycast</td>
                <td class="px-4 py-2">Alpha</td>
                <td class="px-4 py-2">
                  <a href="https://github.com/jesse-c/extensions/tree/feat/add-kopya/extensions/kopya">
                    https://github.com/jesse-c/extensions/tree/feat/add-kopya/extensions/kopya
                  </a>
                </td>
              </tr>
              <tr class="border-b border-gray-300">
                <td class="px-4 py-2">Emacs</td>
                <td class="px-4 py-2">Alpha</td>
                <td class="px-4 py-2">
                  <a href="https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/lisp/kopya.el">
                    https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/lisp/kopya.el
                  </a>
                </td>
              </tr>
              <tr>
                <td class="px-4 py-2">Terminal</td>
                <td class="px-4 py-2">Planned</td>
                <td class="px-4 py-2"></td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="mt-4 flex flex-row space-x-2">
          <a
            class="bg-blue-500 text-white px-2 py-px rounded hover:bg-blue-600 text-sm no-underline transition-colors"
            href="https://github.com/jesse-c/kopya/issues/new"
            target="_blank"
          >
            Request
          </a>
          <a
            class="bg-blue-500 text-white px-2 py-px rounded hover:bg-blue-600 text-sm no-underline transition-colors"
            href="https://github.com/jesse-c/kopya/issues/new"
            target="_blank"
          >
            Add yours
          </a>
        </div>
      </div>

      <div class="p-4 flex flex-col md:flex-row">
        <div id="features" class="md:w-1/2">
          <h2 class="text-xl font-bold mb-4">Features</h2>
          <ul class="list-disc pl-5 space-y-2">
            <li>Full offline history in accessible DB</li>
            <li>List, search, and delete entries</li>
            <li>Support for text, RTF, and images</li>
            <li>Temporary private copying mode</li>
            <li>Open source</li>
          </ul>
        </div>

        <div id="roadmap" class="md:w-1/2">
          <h2 class="text-xl font-bold mb-4">Roadmap</h2>
          <ul class="list-disc pl-5 space-y-2">
            <li>Auto-start at login</li>
            <li>Releases and installation instructions for integrations</li>
            <li>Exclusion rules for patterns, such as secrets</li>
            <li>Exclusion rules for apps</li>
            <li>Cross-computer syncing</li>
            <li>Scripting/Hooks</li>
          </ul>
        </div>
      </div>

      <div id="installation" class="p-4">
        <h2 class="text-xl font-bold mb-4">Installation</h2>
        <p>
          It's a manual process. The repository for Kopya has releases to download or it can be compiled locally. Each integration will either have instructions or rely upon experience with those ecosystems to get them running.
        </p>
      </div>

      <div id="motivation" class="p-4">
        <h2 class="text-xl font-bold mb-4">Motivation</h2>
        <h3 class="text-lg font-semibold mb-2">Why not the existing clipboard managers?</h3>
        <p class="mb-4">There's regularly new clipboard managers popping up.</p>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div class="border border-gray-300 rounded-lg overflow-hidden text-xs">
            <div class="flex items-start p-4">
              <div class="flex-shrink-0 mr-3">
                <img src={~p"/images/finder-icon.png"} alt="Profile" class="w-6 h-6 rounded-full" />
              </div>
              <div>
                <div class="flex items-center">
                  <span>r/macapps</span>
                  <span class="text-gray-500 ml-2">· 3mo ago</span>
                </div>
                <p class="mt-1">The attempt to make the best clipboard manager yet</p>
                <div class="mt-2">
                  <span>3 votes · 74 comments</span>
                </div>
              </div>
            </div>
          </div>

          <div class="border border-gray-300 rounded-lg overflow-hidden text-xs">
            <div class="flex items-start p-4">
              <div class="flex-shrink-0 mr-3">
                <img src={~p"/images/finder-icon.png"} alt="Profile" class="w-6 h-6 rounded-full" />
              </div>
              <div>
                <div class="flex items-center">
                  <span>r/macapps</span>
                  <span class="text-gray-500 ml-2">· 3mo ago</span>
                </div>
                <p class="mt-1">
                  I built a better clipboard app for MacOS because the current options didn't meet my needs! 🚀📋
                </p>
                <div class="mt-2">
                  <span>85 votes · 123 comments</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="max-w-lg border border-gray-300 rounded-lg overflow-hidden mb-4 text-xs">
          <div class="flex items-start p-4">
            <div class="flex-shrink-0 mr-3">
              <img src={~p"/images/finder-icon.png"} alt="Profile" class="w-6 h-6 rounded-full" />
            </div>
            <div>
              <div class="flex items-center">
                <span>r/macapps</span>
                <span class="text-gray-500 ml-2">· 2mo ago</span>
              </div>
              <p class="mt-1">
                I made my commercial clipboard manager open source because it's right
              </p>
              <div class="mt-2">
                <span>29 votes · 12 comments</span>
              </div>
            </div>
          </div>
        </div>

        <div class="space-y-2">
          <p>
            There's even a helpfully
            <a
              href="https://docs.google.com/spreadsheets/d/1JqyglRJXzxaj8OcQw9jHabxFUdsv9iWJXMPXcL7On0M/"
              target="_blank"
            >
              maintained list
            </a>
            of them, that as of 2025-05-01, has 34 entries.
          </p>

          <p>
            They're a little different, since our individual needs have fundamental, little differences.
          </p>

          <p>
            Kopya gives you control over how and where you use it. That means that we can share the basics of a clipboard history engine, and then adapt it as a tool to your ways of working.
          </p>

          <p>The others have set ways to be used, that you adapt to.</p>

          <h3 class="text-lg font-semibold mb-2">Does this apply to other <em>things</em>?</h3>

          <p>
            <a href={
              ~p"/blog/multi-uis-for-a-daemon-and-using-grpc-to-communicate-locally-from-rust-swift"
            }>
              Yes!
            </a>
            I've worked on an equivalent for your <a href={~p"/blog/tags/himalaya"}>
              emails</a>. It's also agent friendly.
          </p>
        </div>
      </div>
    </div>
    """
  end
end
