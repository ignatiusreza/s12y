defmodule S12y.Registries.Hexpm.Registry do
  alias S12y.Registries.Hexpm.Package

  @api_root "https://hex.pm/api"

  def lookup(package, version) do
    initialize(package, version)
    |> lookup_package
    |> lookup_version
  end

  defp initialize(package, version), do: %Package{name: package, version: version}

  defp lookup_package(package) do
    package
    |> Package.cache_response(HTTPoison.get(package_endpoint(package)))
    |> Package.update_version()
    |> Package.update_repo()
    |> Package.update_maintainer()
    |> Package.clear_response()
  end

  defp lookup_version({:error, package}), do: {:error, package}

  defp lookup_version({:ok, package}) do
    package
    |> Package.cache_response(HTTPoison.get(version_endpoint(package)))
    |> Package.update_dependencies()
    |> Package.clear_response()
  end

  defp package_endpoint(package), do: Path.join([@api_root, "packages", package.name])

  defp version_endpoint(package) do
    Path.join([package_endpoint(package), "releases", package.version])
  end
end
