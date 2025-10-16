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

  def render("400.html", assigns) do
    ~H"""
    <.root
      inner_content={bad_request(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("401.html", assigns) do
    ~H"""
    <.root
      inner_content={unauthorized(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("403.html", assigns) do
    ~H"""
    <.root
      inner_content={forbidden(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("405.html", assigns) do
    ~H"""
    <.root
      inner_content={method_not_allowed(assigns)}
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

  def render("408.html", assigns) do
    ~H"""
    <.root
      inner_content={request_timeout(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("429.html", assigns) do
    ~H"""
    <.root
      inner_content={too_many_requests(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("502.html", assigns) do
    ~H"""
    <.root
      inner_content={bad_gateway(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("503.html", assigns) do
    ~H"""
    <.root
      inner_content={service_unavailable(assigns)}
      flash={%{}}
      contributions={Contributions.all_contributions()}
      posts={Blog.all_posts()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end

  def render("504.html", assigns) do
    ~H"""
    <.root
      inner_content={gateway_timeout(assigns)}
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

  defp bad_request(assigns) do
    ~H"""
    <p class="text-sm">Sorry, the request could not be processed due to invalid parameters.</p>
    """
  end

  defp unauthorized(assigns) do
    ~H"""
    <p class="text-sm">Sorry, you are not authorized to access this resource.</p>
    """
  end

  defp forbidden(assigns) do
    ~H"""
    <p class="text-sm">Sorry, access to this resource is forbidden.</p>
    """
  end

  defp method_not_allowed(assigns) do
    ~H"""
    <p class="text-sm">Sorry, this HTTP method is not allowed for this resource.</p>
    """
  end

  defp not_acceptable(assigns) do
    ~H"""
    <p class="text-sm">
      Sorry, the requested format is not acceptable. The server cannot produce a response matching the list of acceptable values.
    </p>
    """
  end

  defp request_timeout(assigns) do
    ~H"""
    <p class="text-sm">Sorry, the request took too long to process and timed out.</p>
    """
  end

  defp too_many_requests(assigns) do
    ~H"""
    <p class="text-sm">Sorry, you have made too many requests. Please try again later.</p>
    """
  end

  defp bad_gateway(assigns) do
    ~H"""
    <p class="text-sm">Sorry, we received an invalid response from an upstream server.</p>
    """
  end

  defp service_unavailable(assigns) do
    ~H"""
    <p class="text-sm">Sorry, the service is temporarily unavailable. Please try again later.</p>
    """
  end

  defp gateway_timeout(assigns) do
    ~H"""
    <p class="text-sm">Sorry, the gateway timed out while waiting for a response.</p>
    """
  end
end
