defmodule PersonalSite.SentryFilter do
  @moduledoc """
  Sentry `before_send` callback.

  Drops expected non-500 exceptions (e.g. blog/tag 404s and no-route errors)
  so they are not sent to Sentry and do not consume the error budget.
  """

  def before_send(%Sentry.Event{original_exception: %PersonalSite.Blog.NotFoundError{}}), do: nil

  def before_send(%Sentry.Event{original_exception: %Phoenix.Router.NoRouteError{}}), do: nil

  def before_send(event), do: event
end
