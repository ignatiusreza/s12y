defmodule S12y.Parsers.WorkerTest do
  use ExUnit.Case, async: true
  import S12y.Fixture

  alias S12y.Parsers.Worker

  describe "Worker.Registry" do
    setup do
      project = project_fixture()

      %{project: project}
    end

    test "parse runs", %{project: project} do
      assert {:ok, _} = Worker.parse(project)
    end
  end
end
