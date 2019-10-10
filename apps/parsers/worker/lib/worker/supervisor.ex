defmodule S12y.Parsers.Worker.Supervisor do
  use Supervisor

  alias S12y.Parsers.Worker

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Task.Supervisor, name: Worker.Task},
      {Worker.Runtime, name: Worker.Runtime}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
