defmodule PersonalSite.SentryEventFilter do
  @moduledoc """
  Custom Sentry event filter.

  Allows `Phoenix.Router.NoRouteError` through to the `before_send` callback
  (where it is downgraded to "info" level) instead of dropping it entirely.
  All other exceptions delegate to `Sentry.DefaultEventFilter`.
  """

  @behaviour Sentry.EventFilter

  @impl true
  def exclude_exception?(%Phoenix.Router.NoRouteError{}, :plug), do: false

  def exclude_exception?(exception, source),
    do: Sentry.DefaultEventFilter.exclude_exception?(exception, source)
end
