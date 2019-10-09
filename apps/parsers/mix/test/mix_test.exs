defmodule S12y.Parsers.MixTest do
  use ExUnit.Case
  use S12y.Parsers.Fixtures

  alias S12y.Parsers

  generate do
    test "parse input into output", %{fixture: fixture} do
      {:ok, input} = read_input(fixture)
      {:ok, output} = read_output(fixture)

      parsed = Parsers.Mix.parse(input)

      assert Jason.decode!(parsed) == Jason.decode!(output)
    end
  end
end
