defmodule PersonalSite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_env = redis_env()

    children = [
      # Start the Telemetry supervisor
      PersonalSiteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PersonalSite.PubSub},
      # Start the Endpoint (http/https)
      PersonalSiteWeb.Endpoint,
      PersonalSiteWeb.Presence,
      # Start a worker by calling: PersonalSite.Worker.start_link(arg)
      # {PersonalSite.Worker, arg}
      {PersonalSite.Shoutbox, []},
      {
        Redix,
        {
          redis_env[:url],
          Keyword.merge(redis_env[:opts], name: PersonalSite.Redis.name())
        }
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PersonalSite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PersonalSiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def redis_env do
    if Application.get_env(:testcontainers, :enabled, false) do
      {:ok, _} = Testcontainers.start_link()
      config = Testcontainers.RedisContainer.new()
      {:ok, container} = Testcontainers.start_container(config)

      [
        url: Testcontainers.RedisContainer.connection_url(container),
        opts: []
      ]
    else
      Application.get_env(:personal_site, PersonalSite.Redis)
    end
  end
end
