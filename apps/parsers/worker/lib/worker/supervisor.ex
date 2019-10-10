defmodule S12y.Parsers.Worker.Supervisor do
  use Supervisor

  alias S12y.Parsers.Worker

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Worker.RuntimeSupervisor, strategy: :one_for_one},
      {Worker.Registry, name: Worker.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
