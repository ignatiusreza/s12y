defmodule S12y.Parsers.Worker.Runtime do
  use GenServer

  alias S12y.PubSub.Broadcast
  alias S12y.Parsers.Worker

  # Client

  def start_link(args) do
    GenServer.start_link(__MODULE__, :ok, args)
  end

  def parse(project) do
    GenServer.call(__MODULE__, {:parse, project})
  end

  # Server

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:parse, project}, _from, state) do
    # The actual parsing process is done asynchronously inside a worker task
    # so that it won't block the caller process, and so that caller won't crash in case the task failed
    {:ok, pid} = Task.Supervisor.start_child(Worker.Task, Worker.Task, :parse, [project])
    Process.monitor(pid)
    {:reply, {:ok, pid}, Map.put(state, pid, project)}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, error}, state) do
    unless error == :normal, do: Broadcast.project(:parse_failed, {Map.get(state, pid), error})

    {:noreply, Map.delete(state, pid)}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
