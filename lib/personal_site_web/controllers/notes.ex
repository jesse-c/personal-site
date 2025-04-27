defmodule PersonalSiteWeb.NotesController do
  use PersonalSiteWeb, :controller

  def index(conn, _params) do
    Phoenix.Controller.redirect(conn, to: ~p"/blog")
  end

  def single(conn, params) do
    slug =
      case params["id"] do
        "initial-release-of-semantic-search-for-notes-app" ->
          "initial-release-of-hybrid-search-for-notes-app"

        "v1-of-raycast-extension-for-himalaya" ->
          "v1-of-raycast-extension-for-himalaya-released"

        slug ->
          slug
      end

    Phoenix.Controller.redirect(conn, to: ~p"/blog/#{slug}")
  end
end
