defmodule S12y.Registries.Worker.Task do
  alias S12y.CLI
  alias S12y.PubSub.Broadcast

  # TODO: add support for uploading multiple configurations per project
  def parse(project) do
    project
    |> prepare_project
    |> write_configuration
    |> invoke_parser
    |> broadcast(project)
  end

  defp prepare_project(project) do
    :ok =
      project
      |> project_path
      |> File.mkdir_p()

    project
  end

  defp write_configuration(%{configurations: [configuration]} = project) do
    :ok =
      project
      |> project_path(configuration.filename)
      |> File.write(configuration.content)

    project
  end

  defp invoke_parser(%{configurations: [configuration]} = project) do
    configuration.parser
    |> CLI.parser_path()
    |> (fn path -> CLI.run("bin/run.sh", [project.id], cd: path) end).()
  end

  def broadcast({:ok, parsed} = passthrough, project) do
    Broadcast.project(:parsed, {project, parsed})

    passthrough
  end

  def broadcast({:error, error} = passthrough, project) do
    Broadcast.project(:parse_failed, {project, error})

    passthrough
  end

  def project_path(project, filename), do: Path.expand(filename, project_path(project))

  def project_path(%{id: id, configurations: [configuration]}),
    do: CLI.parser_path(configuration.parser, "tmp/#{id}")
end
