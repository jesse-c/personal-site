defmodule PersonalSiteWeb.NotesController do
  @moduledoc """
  Redirects from the previous notes naming to the new blog/posts naming.
  """
  use PersonalSiteWeb, :controller

  def index(conn, _params) do
    Phoenix.Controller.redirect(conn, to: ~p"/blog")
  end

  def single(conn, params), do: Phoenix.Controller.redirect(conn, to: ~p"/blog/#{params["id"]}")
end
