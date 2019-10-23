defmodule S12y.Registries.Worker.TaskTest do
  use S12y.Registries.Worker.TestCase
  import S12y.Fixture

  alias S12y.Registries.Worker

  defmodule Subscription, do: use(S12y.PubSub.SubscriptionCase, topic: "dependency")

  @moduletag :docker

  describe "Worker.Task" do
    setup do
      {:ok, _pid} = start_supervised(Subscription)

      :ok
    end

    test "lookup of supported project dependency broadcast lookup result" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(),
           fixture <- read_fixture!("registries/hexpm/phoenix/output") do
        assert [] = Subscription.reset()
        assert {:ok, _} = Worker.Task.lookup(dependency)
        assert [{:lookup, {^dependency, output}}] = Subscription.state()
        assert Map.get(Jason.decode!(fixture), "name") == Map.get(Jason.decode!(output), "name")
      end
    end

    test "lookup of unknown project dependency broadcast lookup_failed" do
      with {:ok, %{dependency: dependency}} <- dependency_fixture(unknown_dependency_attrs()),
           error <- read_fixture!("registries/hexpm/unknown/output") do
        assert [] == Subscription.reset()
        assert {:error, {error, 1}} == Worker.Task.lookup(dependency)
        assert [{:lookup_failed, {dependency, {error, 1}}}] == Subscription.state()
      end
    end
  end
end
