defmodule S12y.Registries.Worker.Application do
  use Application

  alias S12y.Registries.Worker

  @impl true
  def start(_type, _args) do
    Worker.Supervisor.start_link(name: Worker.Supervisor)
  end
end
