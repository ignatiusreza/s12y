defmodule S12y.Parsers.Worker.Runtime do
  use GenServer

  alias S12y.Parsers.Worker

  # Client

  def start_link(args) do
    project = Keyword.get(args, :project)

    GenServer.start_link(__MODULE__, project, args)
  end

  def parse(project) do
    {:ok, runtime} = Worker.Registry.start_child(Worker.Registry, project)

    # TODO: given that we want it to do one thing, should we use Task instead of GenServer? how to isolate crashed Task?
    result = GenServer.call(runtime, {:parse})
    GenServer.stop(runtime)
    result
  end

  # Server

  @impl true
  def init(project) do
    {:ok, %{project: project}}
  end

  @impl true
  def handle_call({:parse}, _from, %{project: project} = state) do
    {:reply, {:ok, project}, state}
  end
end
