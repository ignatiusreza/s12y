defmodule S12y.Parsers.Worker.TaskTest do
  use S12y.Parsers.Worker.TestCase, async: true
  import S12y.Fixture

  alias S12y.Parsers.Worker

  describe "Worker.Task" do
    setup do
      project = project_fixture()

      %{project: project}
    end

    test "parsing supported project configurations", %{project: project} do
      assert {:ok, _} = Worker.Task.parse(project)
    end
  end
end
