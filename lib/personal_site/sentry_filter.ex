defmodule PersonalSite.SentryFilter do
  @moduledoc """
  Sentry `before_send` callback.

  Downgrades expected non-500 exceptions (e.g. blog/tag 404s) to "info" level
  so they are collected in Sentry but do not trigger error-level alerts.
  """

  def before_send(%Sentry.Event{original_exception: %PersonalSite.Blog.NotFoundError{}} = event) do
    %{event | level: "info"}
  end

  def before_send(%Sentry.Event{original_exception: %Phoenix.Router.NoRouteError{}} = event) do
    %{event | level: "info"}
  end

  def before_send(event), do: event
end
