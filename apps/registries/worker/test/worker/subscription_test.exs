defmodule S12y.Registries.Worker.SubscriptionTest do
  use S12y.Registries.Worker.TestCase
  import S12y.Fixture

  alias S12y.Registries.Worker
  alias S12y.Project

  describe "Worker.Subscription.handle_message(:parsed)" do
    @fixture read_fixture!("parsers/mix/phoenix_new/output")

    setup do
      project = project_fixture()
      example = fn -> Worker.Subscription.handle_message(:parsed, {project, @fixture}) end

      %{project: project, example: example}
    end

    test "mark the project as parsed", %{project: project, example: example} do
      refute Project.parsed?(project)

      {:ok, project} = example.()

      assert Project.parsed?(project)
    end

    test "does not mark the project parsing as failed", %{example: example} do
      {:ok, project} = example.()

      refute Project.parse_failed?(project)
    end

    test "saves the parsed dependency to database", %{project: project, example: example} do
      assert Project.count_dependencies(project) == 0

      {:ok, project} = example.()

      assert Project.count_dependencies(project) == 10
    end
  end

  describe "Worker.Subscription.handle_message(:parse_failed)" do
    @fixture read_fixture!("parsers/mix/malformed/output")

    setup do
      project = project_fixture(malformed_project_attrs())

      example = fn ->
        Worker.Subscription.handle_message(:parse_failed, {project, {@fixture, 1}})
      end

      %{project: project, example: example}
    end

    test "does not mark the project as parsed", %{example: example} do
      {:ok, project} = example.()

      refute Project.parsed?(project)
    end

    test "mark the project parsing as failed", %{project: project, example: example} do
      refute Project.parse_failed?(project)

      {:ok, project} = example.()

      assert Project.parse_failed?(project)
      assert project.parse_error == @fixture
    end

    test "does not save new dependencies to database", %{example: example} do
      before = Project.count_dependencies()

      example.()

      assert Project.count_dependencies() == before
    end
  end
end
