defmodule S12y.CLI do
  @parsers_path Path.expand("../../parsers", __DIR__)

  def run(path, args) do
    {:ok, cwd} = File.cwd()

    case System.cmd("sh", ["#{cwd}/#{path}" | args]) do
      {result, 0} ->
        {:ok, result}

      err ->
        {:error, err}
    end
  end

  def change_path(path, callback) do
    {:ok, cwd} = File.cwd()

    try do
      :ok = File.mkdir_p(path)
      :ok = File.cd(path)
      callback.()
    after
      File.cd(cwd)
    end
  end

  def parsers_path, do: @parsers_path
  def parser_path(parser), do: Path.expand(parser, @parsers_path)
end
