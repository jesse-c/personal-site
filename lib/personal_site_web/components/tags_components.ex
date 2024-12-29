defmodule PersonalSiteWeb.TagsComponents do
  @moduledoc false

  use Phoenix.Component

  def inline(assigns) do
    ~H"""
    <%= for {tag, index} <- Enum.with_index(@tags) do %>
      <%= if index == length(@tags) - 1 do %>
        <.link navigate={"/blog/tags/#{tag}"}>{tag}</.link>
      <% else %>
        <.link navigate={"/blog/tags/#{tag}"}>{tag}</.link><span>, </span>
      <% end %>
    <% end %>
    """
  end
end
