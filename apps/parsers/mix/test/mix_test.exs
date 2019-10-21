defmodule S12y.Parsers.MixTest do
  use ExUnit.Case
  use S12y.Parsers.Fixtures

  alias S12y.Parsers

  generate do
    setup %{fixture: fixture} do
      {:ok, input} = prepare_input(fixture)
      {:ok, output} = read_output(fixture)

      %{input: input, output: output}
    end

    test "parse input into output", %{input: input, output: output} do
      case Parsers.Mix.parse(input) do
        {:ok, parsed} ->
          assert Jason.decode!(parsed) == Jason.decode!(output)

        {:error, {actual, _}} ->
          assert actual == output
      end
    end
  end
end
