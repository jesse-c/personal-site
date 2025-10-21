import Config
import Dotenvy

source([".env", ".env.\#{config_env()}", System.get_env()])

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/personal_site start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :personal_site, PersonalSiteWeb.Endpoint, server: true
end

config :personal_site, PersonalSite.Shoutbox, clear: 10_000

config :personal_site, PersonalSite.Redis, connection_attempts: 50

config :personal_site, PersonalSiteWeb.Pushover,
  enabled: env!("PUSHOVER_ENABLED", :boolean, false),
  api_key: env!("PUSHOVER_API_KEY", :string!, ""),
  user_key: env!("PUSHOVER_USER_KEY", :string!, "")

config :personal_site, PersonalSite.Plausible,
  enabled: true,
  api_key: env!("PLAUSIBLE_API_KEY", :string, "")

if config_env() == :dev do
  config :personal_site, PersonalSite.Plausible,
    enabled: false,
    data_domain: nil,
    api_key: ""

  config :personal_site, PersonalSite.Redis,
    url: "redis://localhost:6379/0",
    # No options to overwrite from the URI
    opts: []

  config :personal_site, PersonalSite.Shoutbox, max: 5

  config :personal_site, PersonalSite.InstagramDupeChecker, url: "[::1]", port: 8800
end

if config_env() == :test do
  config :personal_site, PersonalSite.Plausible,
    enabled: false,
    data_domain: nil,
    api_key: ""

  config :personal_site, PersonalSite.Shoutbox, max: 2

  config :personal_site, PersonalSite.InstagramDupeChecker, url: "[::1]", port: 8800
end

config :tzdata, :autoupdate, :disabled

if config_env() == :prod do
  config :sentry,
    dsn: env!("SENTRY_DSN", :string!),
    environment_name: :prod,
    traces_sample_rate: 1.0,
    integrations: [
      telemetry: [
        report_handler_failures: true
      ]
    ]

  config :personal_site, :logger, [
    {:handler, :my_sentry_handler, Sentry.LoggerHandler,
     %{
       config: %{
         capture_log_messages: true,
         level: :error,
         metadata: [:file, :line]
       }
     }}
  ]

  # config :opentelemetry, span_processor: {Sentry.OpenTelemetry.SpanProcessor, []}
  # config :opentelemetry, sampler: {Sentry.OpenTelemetry.Sampler, []}
  config :opentelemetry, traces_exporter: :none

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host =
    System.get_env("PHX_HOST") ||
      raise """
      environment variable PHX_HOST is missing.
      """

  host_alt = System.get_env("PHX_HOST_ALT")

  hosts = Enum.filter([host, host_alt], &(&1 != nil))

  port =
    String.to_integer(
      System.get_env("PORT") ||
        raise("""
        environment variable PORT is missing.
        """)
    )

  # https://plausible.io/docs/plausible-script#can-i-send-stats-to-multiple-dashboards-at-the-same-time
  config :personal_site, PersonalSite.Plausible, data_domain: Enum.join(hosts, ",")

  config :personal_site, PersonalSite.Redis,
    url:
      System.get_env("REDIS_PRIVATE_URL") ||
        raise("""
        environment variable REDIS_PRIVATE_URL is missing.
        """),
    opts: [
      socket_opts: [:inet6]
    ]

  config :personal_site, PersonalSite.Shoutbox, max: 100

  config :personal_site, PersonalSite.InstagramDupeChecker,
    url: System.get_env("INSTAGRAM_DUPE_CHECKER_URL"),
    port: System.get_env("INSTAGRAM_DUPE_CHECKER_PORT")

  check_origin =
    [host, host_alt]
    |> Enum.filter(&(&1 != nil))
    |> Enum.flat_map(fn host ->
      [
        # Expects `host` to be "xxxx.com"
        "https://#{host}",
        "https://www.#{host}"
      ]
    end)

  config :personal_site, PersonalSiteWeb.Endpoint,
    url: [host: nil, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    check_origin: check_origin

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :personal_site, PersonalSiteWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :personal_site, PersonalSiteWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
