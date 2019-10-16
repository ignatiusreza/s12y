defmodule S12y.ProjectTest do
  use S12y.DataCase, async: true
  import S12y.Fixture

  alias S12y.Project

  defmodule Subscription, do: use(S12y.PubSub.SubscriptionCase, topic: "project")

  describe "projects" do
    @valid_attrs valid_project_attrs()
    @invalid_attrs %{configurations: []}

    setup do
      {:ok, _pid} = start_supervised(Subscription)

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

      assert Subscription.state() == [{:created, project}]
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Project.create_project(@invalid_attrs)
    end

    test "create_project/1 with invalid data does not broadcast any event" do
      assert {:error, %Ecto.Changeset{}} = Project.create_project(@invalid_attrs)

      assert Subscription.state() == []
    end
  end

  describe "configurations" do
    test "get_configuration/1 returns the configuration with given id" do
      configuration = configuration_fixture()
      assert Project.get_configuration(configuration.id).id == configuration.id
    end
  end

  describe "dependencies" do
    @valid_attrs valid_dependencies_attrs()
    @invalid_attrs %{"phoenix" => %{}}

    test "add_dependencies/2 record new dependency into a given project" do
      {:ok, configuration} = configuration_fixture() |> Project.add_dependencies(@valid_attrs)
      [dependency] = configuration.dependencies

      assert 1 == length(configuration.dependencies)
      assert dependency.name == "phoenix"
      assert dependency.repo == "hexpm"
      assert dependency.version == "~> 1.4.9"
    end

    test "add_dependencies/2 automatically remove duplicated dependency" do
      {:ok, first} = configuration_fixture() |> Project.add_dependencies(@valid_attrs)
      {:ok, second} = first |> Project.add_dependencies(@valid_attrs)

      assert 1 == length(second.dependencies)
      assert first.dependencies == second.dependencies
    end

    test "add_dependencies/2 with invalid data return error changeset" do
      assert {:error, :dependencies, %Ecto.Changeset{}, %{}} =
               Project.add_dependencies(configuration_fixture(), @invalid_attrs)
    end
  end
end
