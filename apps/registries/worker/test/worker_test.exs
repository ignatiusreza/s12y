defmodule S12y.Registries.WorkerTest do
  use S12y.Registries.Worker.TestCase
  import S12y.Fixture

  alias S12y.Registries.Worker

  describe "Worker" do
    setup do
      project = project_fixture()

      %{project: project}
    end

    test "parse runs", %{project: project} do
      assert {:ok, _pid} = Worker.parse(project)
    end
  end
end
