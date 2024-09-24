defmodule PersonalSiteWeb.NotesController do
  use PersonalSiteWeb, :controller

  def index(conn, _params) do
    Phoenix.Controller.redirect(conn, to: ~p"/blog")
  end

  def single(conn, params) do
    Phoenix.Controller.redirect(conn, to: ~p"/blog/#{params["id"]}")
  end
end
