defmodule Mix.Tasks.Mix.Parse do
  use Mix.Task

  @shortdoc "Parse arbitrary mix.exs file and return the list of top-level dependencies defined in it."
  def run([id]) do
    id
    |> S12y.Parsers.Mix.parse()
    |> IO.puts()
  end
end
