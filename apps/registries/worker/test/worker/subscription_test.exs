defmodule S12y.Registries.Worker.SubscriptionTest do
  use S12y.Registries.Worker.TestCase
  import S12y.Fixture

  alias S12y.Registries.Worker
  alias S12y.Project

  describe "Worker.Subscription.handle_message(:lookup)" do
    @fixture read_fixture!("registries/hexpm/phoenix/output")

    setup do
      {:ok, %{dependency: dependency}} = dependency_fixture()
      example = fn -> Worker.Subscription.handle_message(:lookup, {dependency, @fixture}) end

      %{dependency: dependency, example: example}
    end

    test "mark the dependency is lookup", %{dependency: dependency, example: example} do
      refute Project.Dependency.lookup?(dependency)

      {:ok, dependency} = example.()

      assert Project.Dependency.lookup?(dependency)
    end

    test "does not mark the dependency parsing as failed", %{example: example} do
      {:ok, dependency} = example.()

      refute Project.Dependency.lookup_failed?(dependency)
    end

    test "saves child dependencies", %{dependency: dependency, example: example} do
      assert Project.count_dependency_children(dependency) == 0

      {:ok, dependency} = example.()

      assert Project.count_dependency_children(dependency) == 5
    end

    test "saves maintainers", %{dependency: dependency, example: example} do
      assert Project.count_maintainers(dependency) == 0

      {:ok, dependency} = example.()

      assert Project.count_maintainers(dependency) == 4
    end
  end

  describe "Worker.Subscription.handle_message(:lookup_failed)" do
    @fixture read_fixture!("registries/hexpm/unknown/output")

    setup do
      {:ok, %{dependency: dependency}} = dependency_fixture(unknown_dependency_attrs())

      example = fn ->
        Worker.Subscription.handle_message(:lookup_failed, {dependency, {@fixture, 1}})
      end

      %{dependency: dependency, example: example}
    end

    test "does not mark the dependency as lookup", %{example: example} do
      {:ok, dependency} = example.()

      refute Project.Dependency.lookup?(dependency)
    end

    test "mark the dependency parsing as failed", %{dependency: dependency, example: example} do
      refute Project.Dependency.lookup_failed?(dependency)

      {:ok, dependency} = example.()

      assert Project.Dependency.lookup_failed?(dependency)
      assert dependency.lookup_error == @fixture
    end

    test "does not save new dependencies to database", %{example: example} do
      before = Project.count_dependencies()

      example.()

      assert Project.count_dependencies() == before
    end

    test "does not save new maintainers to database", %{example: example} do
      before = Project.count_maintainers()

      example.()

      assert Project.count_maintainers() == before
    end
  end
end
