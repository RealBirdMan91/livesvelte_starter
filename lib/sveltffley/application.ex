defmodule Sveltffley.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NodeJS.Supervisor, [path: LiveSvelte.SSR.NodeJS.server_path(), pool_size: 4]},
      SveltffleyWeb.Telemetry,
      Sveltffley.Repo,
      {DNSCluster, query: Application.get_env(:sveltffley, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sveltffley.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Sveltffley.Finch},
      # Start a worker by calling: Sveltffley.Worker.start_link(arg)
      # {Sveltffley.Worker, arg},
      # Start to serve requests, typically the last entry
      SveltffleyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sveltffley.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SveltffleyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end