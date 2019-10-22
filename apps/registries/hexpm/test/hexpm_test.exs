defmodule S12y.Registries.HexpmTest do
  use ExUnit.Case
  use S12y.Registries.Fixtures
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias S12y.Registries

  generate do
    test "lookup certain package up on the registry", %{fixture: fixture} do
      {:ok, input} = read_input(fixture)
      {:ok, output} = read_output(fixture)

      [package, version] = Jason.decode!(input)

      response =
        use_cassette fixture do
          Registries.Hexpm.lookup(package, version)
        end

      case response do
        {:ok, detail} ->
          assert normalize(detail) == Jason.decode!(output)

        {:error, error} ->
          assert error == Jason.decode!(output)
      end
    end
  end

  def normalize(struct) do
    Jason.encode!(struct)
    |> Jason.decode!()
  end
end
