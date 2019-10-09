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
      parsed = Parsers.Mix.parse(input)

      assert Jason.decode!(parsed) == Jason.decode!(output)
    end
  end
end
