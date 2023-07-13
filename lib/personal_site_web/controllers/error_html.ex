defmodule PersonalSiteWeb.ErrorHTML do
  use PersonalSiteWeb, :html

  alias PersonalSite.Notes
  alias PersonalSite.Projects
  alias PersonalSite.Works

  import PersonalSiteWeb.Layouts, only: [root: 1]

  def render(template, assigns) do
    ~H"""
    <.root
      inner_content={Phoenix.Controller.status_message_from_template(template)}
      flash={%{}}
      notes={Notes.all_notes()}
      projects={Projects.all_projects()}
      works={Works.all_works()}
    />
    """
  end
end
