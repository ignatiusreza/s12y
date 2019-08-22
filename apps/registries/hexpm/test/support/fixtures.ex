defmodule S12y.Registries.Fixtures do
  use ExUnit.CaseTemplate

  using do
    quote do
      import S12y.Registries.Fixtures

      setup_all do
        HTTPoison.start()
      end
    end
  end

  @fixtures_path Path.expand("../../../../../fixtures/registries/hexpm", __DIR__)
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

  def read_input(fixture), do: read_fixture(fixture, "input")
  def read_output(fixture), do: read_fixture(fixture, "output")

  defp read_fixture(fixture, filename) do
    "#{fixture}/#{filename}"
    |> Path.expand(@fixtures_path)
    |> File.read()
  end
end
