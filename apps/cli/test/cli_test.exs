defmodule S12y.CLITest do
  use ExUnit.Case

  alias S12y.CLI

  test "run allows running arbitrary sh script" do
    script = Path.expand("support/echo.sh", __DIR__)

    assert {:ok, "ping\n"} == CLI.run(script, ["ping"])
  end
end
