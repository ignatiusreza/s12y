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

  @doc """
  Update project, mark it as parsed, and record its dependencies
  """
  def parsed(project, dependencies) do
    %{configurations: [configuration]} = project

    multi =
      Multi.new()
      |> Multi.run(:configuration, fn _, _ -> add_dependencies(configuration, dependencies) end)
      |> Multi.run(:project, fn _, _ ->
        project
        |> Ecto.Changeset.change(%{parsed_at: current_time()})
        |> Repo.update()
      end)
      |> Repo.transaction()

    with {:ok, %{project: project}} <- multi do
      {:ok, project}
    end
  end

  def parse_failed(project, error) do
    project
    |> Ecto.Changeset.change(%{parse_failed_at: current_time(), parse_error: error})
    |> Repo.update()
  end

  def parsed?(project), do: !!project.parsed_at
  def parse_failed?(project), do: !!project.parse_failed_at

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
  Lookup a single project's dependency by id.
  """
  def get_dependency(id) do
    Project.Dependency
    |> Repo.get(id)
    |> Repo.preload(:children)
  end

  @doc """
  Add dependencies into a given project's configuration.
  """
  def add_dependencies(%Project.Configuration{} = configuration, dependencies) do
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
        dependencies = (dependencies ++ configuration.dependencies) |> Enum.uniq_by(& &1.id)

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

  @doc """
  Add nested dependencies into a dependency.
  """
  def add_dependencies(%Project.Dependency{} = dependency, dependencies) do
    multi =
      Multi.new()
      |> Multi.run(:children, fn _, _ ->
        dependencies
        |> Enum.reduce({:ok, []}, fn {name, dependency}, prev ->
          with {:ok, children} <- prev,
               {:ok, child} <- find_or_create_dependency(Map.put(dependency, "name", name)) do
            {:ok, [child | children]}
          end
        end)
      end)
      |> Multi.run(:parent, fn _, %{children: children} ->
        # preload children
        dependency = Project.get_dependency(dependency.id)
        children = (children ++ dependency.children) |> Enum.uniq_by(& &1.id)

        dependency
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:children, children)
        |> Repo.update()
      end)
      |> Repo.transaction()

    with {:ok, %{parent: dependency}} <- multi do
      {:ok, dependency}
    end
  end

  def count_dependencies do
    from(c in Project.Dependency)
    |> Repo.aggregate(:count, :id)
  end

  def count_dependencies(%Project.Identifier{} = project) do
    ids = Enum.map(project.configurations, & &1.id)

    from(c in "configurations_dependencies", where: c.configuration_id in ^ids)
    |> Repo.aggregate(:count, :id)
  end

  def count_dependencies(%Project.Configuration{} = configuration) do
    from(c in "configurations_dependencies", where: c.configuration_id == ^configuration.id)
    |> Repo.aggregate(:count, :id)
  end

  def count_dependency_parents(%Project.Dependency{} = dependency) do
    from(c in "dependencies_dependencies", where: c.child_id == ^dependency.id)
    |> Repo.aggregate(:count, :id)
  end

  def count_dependency_children(%Project.Dependency{} = dependency) do
    from(c in "dependencies_dependencies", where: c.parent_id == ^dependency.id)
    |> Repo.aggregate(:count, :id)
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

  defp current_time do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end

  defp broadcast({:ok, project} = passthrough, action) do
    Broadcast.project(action, project)

    passthrough
  end

  defp broadcast({:error, %Ecto.Changeset{}} = passthrough, _), do: passthrough
end
