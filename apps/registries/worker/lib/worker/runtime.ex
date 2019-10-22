defmodule S12y.Registries.Worker.Runtime do
  use GenServer

  alias S12y.PubSub.Broadcast
  alias S12y.Registries.Worker

  # Client

  def start_link(args) do
    GenServer.start_link(__MODULE__, :ok, args)
  end

  def lookup(dependency) do
    GenServer.call(__MODULE__, {:lookup, dependency})
  end

  # Server

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, dependency}, _from, state) do
    # The actual parsing process is done asynchronously inside a worker task
    # so that it won't block the caller process, and so that caller won't crash in case the task failed
    {:ok, pid} = Task.Supervisor.start_child(Worker.Task, Worker.Task, :lookup, [dependency])
    Process.monitor(pid)
    {:reply, {:ok, pid}, Map.put(state, pid, dependency)}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, error}, state) do
    unless error == :normal do
      Broadcast.dependency(:lookup_failed, {Map.get(state, pid), error})
    end

    {:noreply, Map.delete(state, pid)}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
