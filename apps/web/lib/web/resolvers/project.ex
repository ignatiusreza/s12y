defmodule Web.Resolvers.Project do
  alias S12y.Project

  ### PROJECTS

  def get_project(_parent, %{id: id}, _resolution) do
    case Project.get_project(id) do
      nil ->
        {:error, "Project ID #{id} not found"}

      project ->
        {:ok, project}
    end
  end

  def create_project(_parent, args, _resolution) do
    args
    |> read_uploaded_file()
    |> Project.create_project()
  end

  ### CONFIGURATIONS

  def list_configurations(%Project.Identifier{} = project, _args, _resolution) do
    {:ok, project.configurations}
  end

  ### DEPENDENCIES

  def list_dependencies(%Project.Identifier{} = project, _args, _resolution) do
    {:ok, Project.list_dependencies(project)}
  end

  ### MAINTAINERS

  def list_maintainers(%Project.Identifier{} = project, _args, _resolution) do
    {:ok, Project.list_maintainers(project)}
  end

  ### HELPERS

  defp read_uploaded_file(args) do
    case args do
      %{configurations: configurations} ->
        configurations =
          Enum.map(configurations, fn configuration ->
            case configuration do
              %{content: content} ->
                %{configuration | content: File.read!(content.path)}

              _ ->
                configuration
            end
          end)

        %{args | configurations: configurations}

      _ ->
        args
    end
  end
end
