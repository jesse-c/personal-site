defmodule PersonalSiteWeb.ErrorHTML do
  use PersonalSiteWeb, :html

  alias PersonalSite.Contributions
  alias PersonalSite.Blog
  alias PersonalSite.Projects
  alias PersonalSite.Works

  import PersonalSiteWeb.Layouts, only: [root: 1]

  def render("404.html", assigns) do
    ~H"""
    <.root
      inner_content={not_found(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("500.html", assigns) do
    ~H"""
    <.root
      inner_content={internal_server_error(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("406.html", assigns) do
    ~H"""
    <.root
      inner_content={not_acceptable(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  defp not_found(assigns) do
    ~H"""
    <p class="text-sm">Sorry, the page you are looking for does not exist.</p>
    """
  end

  defp internal_server_error(assigns) do
    ~H"""
    <p class="text-sm">Sorry, we've encountered an internal error.</p>
    """
  end

  defp not_acceptable(assigns) do
    ~H"""
    <p class="text-sm">
      Sorry, the requested format is not acceptable. The server cannot produce a response matching the list of acceptable values.
    </p>
    """
  end
end
