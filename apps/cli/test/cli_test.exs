defmodule S12y.CLITest do
  use ExUnit.Case

  alias S12y.CLI

  test "run allows running arbitrary sh script" do
    CLI.change_path("test/support", fn ->
      assert {:ok, "ping\n"} == CLI.run("echo.sh", ["ping"])
    end)
  end

  test "change_path temporarily changed the working directly" do
    {:ok, cwd_before} = File.cwd()

    CLI.change_path("test/support", fn ->
      {:ok, cwd_during} = File.cwd()

      assert "#{cwd_before}/test/support" == cwd_during
    end)

    {:ok, cwd_after} = File.cwd()

    assert cwd_before == cwd_after
  end
end
