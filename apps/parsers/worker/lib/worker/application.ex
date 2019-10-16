defmodule S12y.Parsers.Worker.Application do
  use Application

  alias S12y.Parsers.Worker

  @impl true
  def start(_type, _args) do
    Worker.Supervisor.start_link(name: Worker.Supervisor)
  end
end
