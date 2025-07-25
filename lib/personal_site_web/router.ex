defmodule PersonalSiteWeb.Router do
  use PersonalSiteWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {PersonalSiteWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :mcp do
    plug(:accepts, ["json"])
  end

  scope "/", PersonalSiteWeb do
    pipe_through(:browser)

    get "/notes", NotesController, :index
    get "/notes/:id", NotesController, :single

    live_session :default do
      live("/", Live.Index)
      live("/blog", Live.BlogIndex)
      live("/blog/tags", Live.BlogTagsIndex)
      live("/blog/tags/:id", Live.BlogTagsSingle)
      live("/blog/:id", Live.BlogSingle)
      live("/projects", Live.ProjectsIndex)
      live("/apps", Live.AppsIndex)
      live("/works", Live.WorksIndex)
      live("/contributions", Live.ContributionsIndex)
      live("/colophon", Live.Colophon)
      live("/about", Live.About)
      live("/contact", Live.Contact)
      live("/education", Live.Education)
      live("/apps/instagram-dupe-checker", Live.InstagramDupeChecker)
    end

    live_session :mini, root_layout: {PersonalSiteWeb.Layouts, :mini} do
      live("/apps/kopya", Live.Kopya)
    end

    get "/feed.xml", FeedController, :index
  end

  scope "/mcp", PersonalSiteWeb do
    pipe_through(:mcp)

    get "/", MCPController, :get_info
    post "/", MCPController, :handle_request
    delete "/", MCPController, :terminate_session
  end

  scope "/", PersonalSiteWeb do
    pipe_through(:api)

    get "/healthz", HealthController, :healthz
  end
end
