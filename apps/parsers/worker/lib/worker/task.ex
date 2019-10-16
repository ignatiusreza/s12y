defmodule S12y.Parsers.Worker.Task do
  alias S12y.CLI

  # TODO: add support for uploading multiple configurations per project
  def parse(project) do
    project
    |> prepare_project
    |> invoke_parser
  end

  defp prepare_project(%{configurations: [configuration]} = project) do
    project
    |> project_path
    |> CLI.change_path(fn ->
      File.write(configuration.filename, configuration.content)
    end)

    project
  end

  defp invoke_parser(%{configurations: [configuration]} = project) do
    configuration.parser
    |> CLI.parser_path()
    |> CLI.change_path(fn -> CLI.run("bin/run.sh", [project.id]) end)
  end

  def project_path(%{id: id, configurations: [configuration]}) do
    configuration.parser
    |> CLI.parser_path()
    |> (&Path.expand("tmp/#{id}", &1)).()
  end
end
