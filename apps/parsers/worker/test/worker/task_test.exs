defmodule S12y.Parsers.Worker.TaskTest do
  use S12y.Parsers.Worker.TestCase
  import S12y.Fixture

  alias S12y.Parsers.Worker

  describe "Worker.Task" do
    setup do
      start_supervised(Worker.SubscriptionTest)

      :ok
    end

    test "parsing supported project configurations broadcast parsed result" do
      project = project_fixture()

      assert [] = Worker.SubscriptionTest.reset()
      assert {:ok, _} = Worker.Task.parse(project)
      assert [{:parsed, {project, "{}\n"}}] == Worker.SubscriptionTest.state()
    end

    @tag :docker
    test "parsing malformed project configurations broadcast parse_failed" do
      project = project_fixture(malformed_project_attrs())

      error = """
      ** (CompileError) mix.exs:9: undefined function deps/0
          (elixir) src/elixir_locals.erl:108: :elixir_locals.\"-ensure_no_undefined_local/3-lc$^0/1-0-\"/2
          (elixir) src/elixir_locals.erl:109: anonymous fn/3 in :elixir_locals.ensure_no_undefined_local/3
          (stdlib) erl_eval.erl:680: :erl_eval.do_apply/6
      """

      assert [] == Worker.SubscriptionTest.reset()
      assert {:error, {error, 1}} == Worker.Task.parse(project)
      assert [{:parse_failed, {project, {error, 1}}}] == Worker.SubscriptionTest.state()
    end
  end
end
