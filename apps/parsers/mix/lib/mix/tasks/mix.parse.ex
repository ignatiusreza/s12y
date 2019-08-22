defmodule Mix.Tasks.Mix.Parse do
  use Mix.Task

  @shortdoc "Parse arbitrary mix.exs and return the list of top-level dependencies defined in it."
  def run([path]) do
    File.read!(path)
    |> S12y.Parsers.Mix.parse()
    |> IO.puts()
  end
end
