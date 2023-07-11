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

  scope "/", PersonalSiteWeb do
    pipe_through(:browser)

    live_session :default do
      live("/", Live.Index)
      live("/notes", Live.NotesIndex)
      live("/notes/:id", Live.NotesSingle)
      live("/projects", Live.ProjectsIndex)
      live("/works", Live.WorksIndex)
      live("/colophon", Live.Colophon)
      live("/about", Live.About)
      live("/contact", Live.Contact)
      live("/education", Live.Education)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PersonalSiteWeb do
  #   pipe_through :api
  # end
end