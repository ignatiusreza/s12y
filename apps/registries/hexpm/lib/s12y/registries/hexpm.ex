defmodule S12y.Registries.Hexpm do
  alias S12y.Registries.Hexpm.Registry

  @doc """
  Lookup requested package info from the registry
  """
  def lookup(package, version) do
    Registry.lookup(package, version)
    |> Jason.encode!()
  end
end
