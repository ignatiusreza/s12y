defmodule S12y.ProjectTest do
  use S12y.DataCase, async: true
  import S12y.Fixture

  alias S12y.Project

  defmodule ProjectSubscription, do: use(S12y.PubSub.SubscriptionCase, topic: "project")
  defmodule DependencySubscription, do: use(S12y.PubSub.SubscriptionCase, topic: "dependency")

  describe "projects" do
    @valid_attrs valid_project_attrs()
    @invalid_attrs %{configurations: []}

    setup do
      {:ok, _pid} = start_supervised(ProjectSubscription)

      :ok
    end

    test "get_project/1 returns the project with given id" do
      project = project_fixture()
      assert Project.get_project(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      assert {:ok, %{} = project} = Project.create_project(@valid_attrs)

      [configuration | _] = project.configurations
      [%{content: content} | _] = @valid_attrs.configurations

      assert configuration.parser == "mix"
      assert configuration.filename == "mix.exs"
      assert configuration.content == content
    end

    test "create_project/1 with valid data broadcast a project :created event" do
      assert {:ok, %{} = project} = Project.create_project(@valid_attrs)

      assert ProjectSubscription.state() == [{:created, project}]
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Project.create_project(@invalid_attrs)
    end

    test "create_project/1 with invalid data does not broadcast any event" do
      assert {:error, %Ecto.Changeset{}} = Project.create_project(@invalid_attrs)

      assert ProjectSubscription.state() == []
    end
  end

  describe "configurations" do
    test "get_configuration/1 returns the configuration with given id" do
      with {:ok, %{configuration: configuration}} <- configuration_fixture() do
        assert Project.get_configuration(configuration.id).id == configuration.id
      end
    end
  end

  describe "dependencies" do
    @valid_attrs valid_dependencies_attrs()
    @nested_attrs valid_nested_dependencies_attrs()
    @transient_attrs %{
      "mime" => %{"repo" => "hexpm", "version" => "~> 1.0"},
      "plug_crypto" => %{"repo" => "hexpm", "version" => "~> 1.0"}
    }
    @invalid_attrs %{"phoenix" => %{}}

    setup do
      {:ok, _pid} = start_supervised(DependencySubscription)

      :ok
    end

    test "get_dependencies/1 return flatten dependencies when project are given" do
      with {:ok, %{project: project, dependency: dependency}} <- dependency_fixture(),
           {:ok, %{children: [child, _]}} <- Project.add_dependencies(dependency, @nested_attrs),
           {:ok, _} <- Project.add_dependencies(child, @transient_attrs),
           dependencies <- Project.get_dependencies(project),
           dependencies <- Enum.map(dependencies, &Map.take(&1, [:name, :repo, :version])) do
        assert [
                 %{name: "phoenix", repo: "hexpm", version: "~> 1.4.9"},
                 %{name: "plug", repo: "hexpm", version: "~> 1.8.1 or ~> 1.9"},
                 %{name: "plug_cowboy", repo: "hexpm", version: "~> 1.0 or ~> 2.0"},
                 %{name: "mime", repo: "hexpm", version: "~> 1.0"},
                 %{name: "plug_crypto", repo: "hexpm", version: "~> 1.0"}
               ] == dependencies
      end
    end

    test "add_dependencies/2 record new dependency into a given project's configuration" do
      with {:ok, %{configuration: configuration}} <- configuration_fixture(),
           {:ok, configuration} <- Project.add_dependencies(configuration, @valid_attrs),
           [dependency] <- configuration.dependencies do
        assert 1 == length(configuration.dependencies)
        assert dependency.name == "phoenix"
        assert dependency.repo == "hexpm"
        assert dependency.version == "~> 1.4.9"
      end
    end

    test "add_dependencies/2 for root dependencies broadcast dependency :created event" do
      with {:ok, %{configuration: configuration}} <- configuration_fixture(),
           {:ok, configuration} <- Project.add_dependencies(configuration, @valid_attrs),
           [dependency] <- configuration.dependencies do
        assert DependencySubscription.state() == [{:created, dependency}]
      end
    end

    test "add_dependencies/2 record nested dependency into a given dependency" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture() do
        assert 0 == Project.count_dependency_parents(dependency)
        assert 0 == Project.count_dependency_children(dependency)

        {:ok, dependency} = Project.add_dependencies(dependency, @nested_attrs)

        assert 0 == Project.count_dependency_parents(dependency)
        assert 2 == Project.count_dependency_children(dependency)
      end
    end

    test "add_dependencies/2 for nested dependencies broadcast dependency :created event" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(),
           [] <- DependencySubscription.reset(),
           {:ok, dependency} <- Project.add_dependencies(dependency, @nested_attrs),
           state <- Enum.map(dependency.children, fn child -> {:created, child} end) do
        sort = fn state ->
          Enum.sort_by(state, fn {:created, dependency} -> dependency.name end)
        end

        assert sort.(DependencySubscription.state()) == sort.(state)
      end
    end

    test "add_dependencies/2 automatically remove duplicated dependency" do
      with {:ok, %{configuration: configuration}} <- configuration_fixture(),
           {:ok, first} <- Project.add_dependencies(configuration, @valid_attrs),
           {:ok, second} <- Project.add_dependencies(first, @valid_attrs) do
        assert 1 == length(second.dependencies)
        assert Enum.map(first.dependencies, & &1.id) == Enum.map(second.dependencies, & &1.id)
      end
    end

    test "add_dependencies/2 with invalid data return error changeset" do
      with {:ok, %{configuration: configuration}} = configuration_fixture() do
        assert {:error, :dependencies, %Ecto.Changeset{}, %{}} =
                 Project.add_dependencies(configuration, @invalid_attrs)
      end
    end

    test "add_dependencies/2 with invalid data does not broadcast any event" do
      with {:ok, %{configuration: configuration}} = configuration_fixture(),
           {:error, _, _, _} <- Project.add_dependencies(configuration, @invalid_attrs) do
        assert DependencySubscription.state() == []
      end
    end
  end

  describe "maintainers" do
    @valid_attrs valid_maintainer_attrs()
    @update_attrs %{
      "chrismccord" => %{
        "email" => "chris@chrismccord.com",
        "url" => "https://hex.pm/api/users/chrismccord"
      },
      "josevalim" => %{
        "email" => "jose.valim@gmail.com",
        "url" => "https://hex.pm/api/users/josevalim"
      },
      "gazler" => %{
        "email" => "gazler@gmail.com",
        "url" => "https://hex.pm/api/users/gazler"
      },
      "jeregrine" => %{
        "email" => "jason@rokkincat.com",
        "url" => "https://hex.pm/api/users/jeregrine"
      }
    }
    @partial_attrs %{"Marvin" => %{}}

    test "get_maintainers/1 return flatten list of maintainers of a given project" do
      with {:ok, %{project: project}} <- maintainer_fixture(),
           maintainers <- Project.get_maintainers(project),
           maintainers <- Enum.map(maintainers, &Map.take(&1, [:handle, :email])),
           maintainers <- Enum.sort_by(maintainers, & &1.handle) do
        assert [
                 %{handle: "chrismccord", email: "chris@chrismccord.com"},
                 %{handle: "josevalim", email: "jose.valim@gmail.com"}
               ] == maintainers
      end
    end

    test "set_maintainers/2 persist the dependency maintainers information" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(),
           {:ok, dependency} <- Project.set_maintainers(dependency, @valid_attrs),
           maintainers <- dependency.maintainers,
           maintainers <- Enum.map(maintainers, &Map.take(&1, [:handle, :email])),
           maintainers <- Enum.sort_by(maintainers, & &1.handle) do
        assert [
                 %{handle: "chrismccord", email: "chris@chrismccord.com"},
                 %{handle: "josevalim", email: "jose.valim@gmail.com"}
               ] == maintainers
      end
    end

    test "set_maintainers/2 able to update the dependency maintainers information adding new ones" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(),
           {:ok, dependency} <- Project.set_maintainers(dependency, @valid_attrs),
           {:ok, dependency} <- Project.set_maintainers(dependency, @update_attrs),
           maintainers <- dependency.maintainers,
           maintainers <- Enum.map(maintainers, &Map.take(&1, [:handle, :email])),
           maintainers <- Enum.sort_by(maintainers, & &1.handle) do
        assert [
                 %{handle: "chrismccord", email: "chris@chrismccord.com"},
                 %{handle: "gazler", email: "gazler@gmail.com"},
                 %{handle: "jeregrine", email: "jason@rokkincat.com"},
                 %{handle: "josevalim", email: "jose.valim@gmail.com"}
               ] == maintainers
      end
    end

    test "set_maintainers/2 able to update the dependency maintainers information removing existing ones" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(),
           {:ok, dependency} <- Project.set_maintainers(dependency, @valid_attrs),
           {:ok, dependency} <-
             Project.set_maintainers(dependency, Map.take(@valid_attrs, ["chrismccord"])),
           maintainers <- dependency.maintainers,
           maintainers <- Enum.map(maintainers, &Map.take(&1, [:handle, :email])),
           maintainers <- Enum.sort_by(maintainers, & &1.handle) do
        assert [%{handle: "chrismccord", email: "chris@chrismccord.com"}] == maintainers

        # ensure that none of the maintainer record is actually deleted, only the association
        assert Project.count_maintainers() == 2
      end
    end

    test "set_maintainers/2 called with partial information still persists" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(),
           {:ok, dependency} <- Project.set_maintainers(dependency, @partial_attrs),
           maintainers <- dependency.maintainers,
           maintainers <- Enum.map(maintainers, &Map.take(&1, [:handle, :email])) do
        assert [%{handle: "Marvin", email: nil}] == maintainers
      end
    end
  end
end
