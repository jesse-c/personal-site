import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :personal_site, PersonalSiteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "guTqXB+b/h0wMw++SAsVXUwKeWdUq8T5ojjiFqXbK5eHHADQPpBf3gzF/35Kx2me",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Use local Redis for tests instead of testcontainers
config :personal_site, PersonalSite.Redis,
  url: "redis://localhost:6379/0",
  opts: []
