defmodule S12y.Parsers.Worker.Registry do
  alias S12y.Parsers.Worker

  @doc """
  Specify how the registry should be starts.
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [Keyword.merge(opts, keys: :unique)]},
      type: :supervisor
    }
  end

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    Registry.start_link(opts)
  end

  @doc """
  Ensures there is a child process associated with the given project.
  """
  def start_child(server, project) do
    case lookup(server, project) do
      {:ok, pid} ->
        {:ok, pid}

      :error ->
        via = {:via, Registry, {server, project.id}}

        DynamicSupervisor.start_child(
          Worker.RuntimeSupervisor,
          %{
            id: Worker.Runtime,
            start: {Worker.Runtime, :start_link, [[name: via, project: project]]},
            restart: :temporary
          }
        )
    end
  end

  @doc """
  Looks up the child process's pid associated with the given project.

  Returns `{:ok, pid}` if the process exists, `:error` otherwise.
  """
  def lookup(server, project) do
    case Registry.lookup(server, project.id) do
      [{pid, nil}] ->
        {:ok, pid}

      _ ->
        :error
    end
  end
end
