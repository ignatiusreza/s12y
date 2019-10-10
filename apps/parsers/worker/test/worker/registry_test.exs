defmodule S12y.Parsers.Worker.RegistryTest do
  use ExUnit.Case, async: true
  import S12y.Fixture

  alias S12y.Parsers.Worker

  describe "Worker.Registry" do
    setup context do
      start_supervised!({Worker.Registry, name: context.test})
      project = project_fixture()

      %{registry: context.test, project: project}
    end

    test "spawns worker runtime", %{registry: registry, project: project} do
      assert Worker.Registry.lookup(registry, project) == :error

      Worker.Registry.start_child(registry, project)
      assert {:ok, runtime} = Worker.Registry.lookup(registry, project)

      # TODO: not sure if introspecting Process.info is a good thing?
      assert Process.info(runtime)[:dictionary][:"$initial_call"] == {Worker.Runtime, :init, 1}
    end

    test "removes runtimes on exit", %{registry: registry, project: project} do
      Worker.Registry.start_child(registry, project)
      {:ok, runtime} = Worker.Registry.lookup(registry, project)

      stop_runtime!(registry, runtime)

      assert Worker.Registry.lookup(registry, project) == :error
    end

    test "removes runtime on crash", %{registry: registry, project: project} do
      Worker.Registry.start_child(registry, project)
      {:ok, runtime} = Worker.Registry.lookup(registry, project)

      stop_runtime!(registry, runtime, :shutdown)

      assert Worker.Registry.lookup(registry, project) == :error
    end

    def stop_runtime!(registry, runtime, reason \\ :normal, timeout \\ :infinity) do
      GenServer.stop(runtime, reason, timeout)

      # ensure the registry processed the DOWN message
      Worker.Registry.start_child(registry, %{id: "404"})
    end
  end
end
