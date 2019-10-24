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
    |> Repo.preload(:maintainers)
  end

  @doc """
  Return flatten dependencies of a single project.
  """
  def list_dependencies(%Project.Identifier{} = project) do
    dependencies_cte(project)
    |> Repo.all()
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

    with {:ok, %{configuration: configuration, dependencies: dependencies}} <- multi do
      broadcast(dependencies, :created)

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

    with {:ok, %{parent: parent, children: children}} <- multi do
      broadcast(children, :created)

      {:ok, parent}
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

  @doc """
  Update dependency details, recording child dependencies if exists
  """
  def lookup(dependency, details) do
    multi =
      Multi.new()
      |> Multi.run(:dependencies, fn _, _ ->
        add_dependencies(dependency, Map.get(details, "dependencies"))
      end)
      |> Multi.run(:maintainers, fn _, _ ->
        set_maintainers(dependency, Map.get(details, "maintainers"))
      end)
      |> Multi.run(:dependency, fn _, _ ->
        dependency
        |> Ecto.Changeset.change(%{lookup_at: current_time()})
        |> Repo.update()
      end)
      |> Repo.transaction()

    with {:ok, %{dependency: dependency}} <- multi do
      {:ok, dependency}
    end
  end

  def lookup_failed(dependency, error) do
    dependency
    |> Ecto.Changeset.change(%{lookup_failed_at: current_time(), lookup_error: error})
    |> Repo.update()
  end

  defp dependencies_cte(project) do
    initial =
      Project.Dependency
      |> join(:inner, [d], c in assoc(d, :configurations))
      |> where([d, c], c.project_id == ^project.id)

    recursion =
      Project.Dependency
      |> join(:inner, [d], ch in assoc(d, :children))

    cte = initial |> union_all(^recursion)

    Project.Dependency
    |> recursive_ctes(true)
    |> with_cte("dependency_tree", as: ^cte)
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

  ### MAINTAINER

  @doc """
  Get a flatten list of maintainers for a given project.
  """
  def list_maintainers(%Project.Identifier{} = project) do
    dependencies = project |> dependencies_cte() |> subquery()

    Project.Maintainer
    |> join(:inner, [m], dm in "dependencies_maintainers", on: m.id == dm.maintainer_id)
    |> join(:inner, [m, dm], d in ^dependencies, on: dm.dependency_id == d.id)
    |> Repo.all()
  end

  @doc """
  Update the list of maintainers of a dependency
  """
  def set_maintainers(%Project.Dependency{} = dependency, maintainers) do
    multi =
      Multi.new()
      |> Multi.run(:maintainers, fn _, _ ->
        maintainers
        |> Enum.reduce({:ok, []}, fn {handle, maintainer}, prev ->
          with {:ok, maintainers} <- prev,
               {:ok, maintainer} <-
                 find_or_create_maintainer(Map.put(maintainer, "handle", handle)) do
            {:ok, [maintainer | maintainers]}
          end
        end)
      end)
      |> Multi.run(:dependency, fn _, %{maintainers: maintainers} ->
        # preload maintainers
        dependency = Project.get_dependency(dependency.id)
        maintainers = maintainers |> Enum.uniq_by(& &1.id)

        dependency
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:maintainers, maintainers)
        |> Repo.update()
      end)
      |> Repo.transaction()

    with {:ok, %{dependency: dependency}} <- multi do
      {:ok, dependency}
    end
  end

  def count_maintainers do
    from(c in Project.Maintainer)
    |> Repo.aggregate(:count, :id)
  end

  def count_maintainers(%Project.Dependency{} = dependency) do
    from(c in "dependencies_maintainers", where: c.dependency_id == ^dependency.id)
    |> Repo.aggregate(:count, :id)
  end

  defp find_or_create_maintainer(attrs), do: find_maintainer(attrs) || create_maintainer(attrs)

  defp find_maintainer(%{"handle" => handle, "email" => email}) do
    query = from d in Project.Maintainer, where: d.handle == ^handle and d.email == ^email

    case Repo.one(query) do
      nil -> nil
      maintainer -> {:ok, maintainer}
    end
  end

  defp find_maintainer(%{handle: _, email: _}) do
    IO.warn(
      "Don't pass in maintainer with atom keys, maintainer are expected to be come from parsed JSON, which have string keys",
      Macro.Env.stacktrace(__ENV__)
    )
  end

  defp find_maintainer(_attrs), do: nil

  defp create_maintainer(attrs) do
    %Project.Maintainer{}
    |> Project.Maintainer.changeset(attrs)
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

  defp broadcast(dependencies, action) do
    Enum.each(dependencies, fn dependency ->
      if dependency.recently_persisted, do: Broadcast.dependency(action, dependency)
    end)
  end
end
