defmodule Mix.Tasks.Mix.Parse do
  use Mix.Task

  @shortdoc "Parse arbitrary mix.exs file and return the list of top-level dependencies defined in it."
  def run([id]) do
    case S12y.Parsers.Mix.parse(id) do
      {:ok, output} ->
        IO.puts(String.trim(output))

      {:error, {output, error}} ->
        IO.puts(String.trim(output))

        exit({:shutdown, error})
    end
  end
end
