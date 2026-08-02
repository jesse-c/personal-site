defmodule PersonalSite.SentryEventFilter do
  @moduledoc """
  Custom Sentry event filter.

  Excludes `Phoenix.Router.NoRouteError` and `PersonalSite.Blog.NotFoundError`
  entirely so they never consume the error budget.
  All other exceptions delegate to `Sentry.DefaultEventFilter`.
  """

  @behaviour Sentry.EventFilter

  @impl true
  def exclude_exception?(%Phoenix.Router.NoRouteError{}, _source), do: true
  def exclude_exception?(%PersonalSite.Blog.NotFoundError{}, _source), do: true

  def exclude_exception?(exception, source),
    do: Sentry.DefaultEventFilter.exclude_exception?(exception, source)
end
