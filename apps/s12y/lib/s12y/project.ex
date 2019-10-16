defmodule S12y.Project do
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias S12y.Project
  alias S12y.PubSub.Broadcast
  alias S12y.Repo

  ### PROJECT

  @doc """
  Lookup a single project by id (uuid)
  """
  def get_project(id) do
    Project.Identifier
    |> Repo.get(id)
    |> Repo.preload(:configurations)
  end

  @doc """
  Creates a project.
  """
  def create_project(attrs) do
    %Project.Identifier{}
    |> Project.Identifier.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  ### CONFIGURATION
  @doc """
  Lookup a single project's configuration by id.
  """
  def get_configuration(id) do
    Project.Configuration
    |> Repo.get(id)
    |> Repo.preload(:dependencies)
  end

  ### DEPENDENCY

  @doc """
  Add dependencies into a given project's configuration.
  """
  def add_dependencies(configuration, dependencies) do
    multi =
      Multi.new()
      |> Multi.run(:dependencies, fn _, _ ->
        dependencies
        |> Enum.reduce({:ok, []}, fn {name, dependency}, prev ->
          with {:ok, dependencies} <- prev,
               {:ok, dependency} <- find_or_create_dependency(Map.put(dependency, "name", name)) do
            {:ok, [dependency | dependencies]}
          end
        end)
      end)
      |> Multi.run(:configuration, fn _multi, %{dependencies: dependencies} ->
        # preload dependencies
        configuration = Project.get_configuration(configuration.id)

        dependencies =
          (dependencies ++ configuration.dependencies)
          |> Enum.uniq_by(& &1.id)

        configuration
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:dependencies, dependencies)
        |> Repo.update()
      end)
      |> Repo.transaction()

    with {:ok, %{configuration: configuration}} <- multi do
      {:ok, configuration}
    end
  end

  defp find_or_create_dependency(attrs) do
    find_dependency(attrs) || create_dependency(attrs)
  end

  defp find_dependency(%{"name" => name, "repo" => repo, "version" => version}) do
    query =
      from d in Project.Dependency,
        where: d.name == ^name and d.repo == ^repo and d.version == ^version

    case Repo.one(query) do
      nil -> nil
      dependency -> {:ok, dependency}
    end
  end

  defp find_dependency(%{name: _, repo: _, version: _}) do
    IO.warn(
      "Don't pass in dependency with atom keys, dependency are expected to be come from parsed JSON, which have string keys",
      Macro.Env.stacktrace(__ENV__)
    )
  end

  defp find_dependency(_attrs), do: nil

  defp create_dependency(attrs) do
    %Project.Dependency{}
    |> Project.Dependency.changeset(attrs)
    |> Repo.insert()
  end


  ### HELPERS

  defp broadcast({:ok, project} = passthrough, action) do
    Broadcast.project(action, project)

    passthrough
  end

  defp broadcast({:error, %Ecto.Changeset{}} = passthrough, _), do: passthrough
end
