defmodule Mix.Tasks.Hexpm.Lookup do
  use Mix.Task

  @shortdoc "Lookup given hexpm package maintainers and dependencies information."
  def run([package, version]) do
    HTTPoison.start()

    S12y.Registries.Hexpm.lookup(package, version)
    |> Jason.encode!()
    |> IO.puts()
  end
end
