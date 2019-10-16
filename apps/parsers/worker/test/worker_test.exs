defmodule S12y.Parsers.WorkerTest do
  use S12y.Parsers.Worker.TestCase, async: true
  import S12y.Fixture

  alias S12y.Parsers.Worker

  describe "Worker.Registry" do
    setup do
      project = project_fixture()

      %{project: project}
    end

    test "parse runs", %{project: project} do
      assert {:ok, _pid} = Worker.parse(project)
    end
  end
end
