defmodule S12y.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      S12y.Repo,
      {Phoenix.PubSub.PG2, name: S12y.PubSub}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: S12y.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
