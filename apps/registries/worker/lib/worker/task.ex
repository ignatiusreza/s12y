defmodule S12y.Registries.Worker.Task do
  alias S12y.CLI
  alias S12y.PubSub.Broadcast

  def lookup(dependency) do
    dependency
    |> registry_lookup
    |> broadcast(dependency)
  end

  defp registry_lookup(dependency) do
    dependency.repo
    |> CLI.registry_path()
    |> (fn path -> CLI.run("bin/run.sh", [dependency.name, dependency.version], cd: path) end).()
  end

  def broadcast({:ok, lookup} = passthrough, dependency) do
    Broadcast.dependency(:lookup, {dependency, lookup})

    passthrough
  end

  def broadcast({:error, error} = passthrough, dependency) do
    Broadcast.dependency(:lookup_failed, {dependency, error})

    passthrough
  end
end
