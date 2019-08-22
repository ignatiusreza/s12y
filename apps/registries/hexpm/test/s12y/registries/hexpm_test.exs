defmodule S12y.Registries.HexpmTest do
  use ExUnit.Case
  use S12y.Registries.Fixtures
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias S12y.Registries

  generate do
    test "parse input into output", %{fixture: fixture} do
      {:ok, input} = read_input(fixture)
      {:ok, output} = read_output(fixture)

      [package, version] = Jason.decode!(input)

      parsed =
        use_cassette fixture do
          Registries.Hexpm.lookup(package, version)
        end

      assert Jason.decode!(parsed) == Jason.decode!(output)
    end
  end
end
