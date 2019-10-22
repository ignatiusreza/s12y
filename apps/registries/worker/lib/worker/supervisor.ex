defmodule S12y.Parsers.Worker.Supervisor do
  use Supervisor

  alias S12y.Parsers.Worker

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    Supervisor.init(children(Mix.env()), strategy: :one_for_all)
  end

  def children() do
    [
      {Task.Supervisor, name: Worker.Task},
      {Worker.Runtime, name: Worker.Runtime}
    ]
  end

  def children(:test), do: children()
  # don't turn on subscription in test environment, since it makes unit testing harder
  def children(_), do: children() ++ [Worker.Subscription]
end
