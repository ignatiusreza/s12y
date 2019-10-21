defmodule S12y.CLI do
  @parsers_path Path.expand("../../parsers", __DIR__)

  def run(path, args, opts \\ []) do
    case System.cmd("sh", [path | args], opts) do
      {result, 0} ->
        {:ok, result}

      err ->
        {:error, err}
    end
  end

  def parsers_path, do: @parsers_path
  def parser_path(parser), do: Path.expand(parser, @parsers_path)
  def parser_path(parser, path), do: Path.expand(path, parser_path(parser))
end
