defmodule Mix.Tasks.Hexpm.Lookup do
  use Mix.Task

  @shortdoc "Lookup given hexpm package maintainers and dependencies information."
  def run([package, version]) do
    HTTPoison.start()

    case S12y.Registries.Hexpm.lookup(package, version) do
      {:ok, package} ->
        package
        |> Jason.encode!()
        |> IO.puts()

      {:error, error} ->
        error
        |> Jason.encode!()
        |> IO.puts()

        exit({:shutdown, 1})
    end
  end
end
