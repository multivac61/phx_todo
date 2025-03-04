defmodule PhxTodo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias PhxTodo.ToDos.ToDo

  @impl true
  def start(_type, _args) do
    children = [
      PhxTodoWeb.Telemetry,
      PhxTodo.Repo,
      {DNSCluster, query: Application.get_env(:phx_todo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhxTodo.PubSub},
      {EctoWatch,
       repo: PhxTodo.Repo,
       pub_sub: PhxTodo.PubSub,
       watchers: [
         {ToDo, :inserted},
         {ToDo, :updated},
         {ToDo, :deleted}
       ]},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhxTodo.Finch},
      # Start a worker by calling: PhxTodo.Worker.start_link(arg)
      # {PhxTodo.Worker, arg},
      # Start to serve requests, typically the last entry
      PhxTodoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxTodo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxTodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
