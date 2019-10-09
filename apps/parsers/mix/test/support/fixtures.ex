defmodule S12y.Parsers.Fixtures do
  use ExUnit.CaseTemplate

  using do
    quote do
      import S12y.Parsers.Fixtures
    end
  end

  @fixtures_path Path.expand("../../../../../fixtures/parsers/mix", __DIR__)
  defmacro generate(do: expression) do
    {:ok, fixtures} = File.ls(@fixtures_path)

    Enum.map(fixtures, fn fixture ->
      quote do
        describe unquote(fixture) do
          setup do
            [fixture: unquote(fixture)]
          end

          unquote(expression)
        end
      end
    end)
  end

  def prepare_input(fixture) do
    id = UUID.uuid4()

    fixture |> input_path |> File.copy!("#{tmp_path(id)}/mix.exs")

    {:ok, id}
  end

  def read_input(fixture), do: fixture |> input_path |> File.read()
  def read_output(fixture), do: fixture |> output_path |> File.read()

  def input_path(fixture), do: "#{fixture}/input" |> Path.expand(@fixtures_path)
  def output_path(fixture), do: "#{fixture}/output" |> Path.expand(@fixtures_path)

  defp tmp_path(path) do
    path = Path.join("/tmp", path)
    File.mkdir_p!(path)
    path
  end
end
