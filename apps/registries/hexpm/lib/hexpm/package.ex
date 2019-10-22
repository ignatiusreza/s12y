defmodule S12y.Registries.Hexpm.Package do
  @derive {Jason.Encoder, only: [:name, :version, :repo, :dependencies, :maintainers]}
  defstruct [:response, :name, :version, :repo, dependencies: [], maintainers: []]

  def cache_response(package, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, %{package | response: Jason.decode!(body)}}
  end

  def cache_response(package, {:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, %{package | response: Jason.decode!(body)}}
  end

  def update_version({:error, package}), do: {:error, package}

  def update_version({:ok, package}) do
    {:ok, %{package | version: matching_release(package)["version"]}}
  end

  def update_repo({:error, package}), do: {:error, package}

  def update_repo({:ok, package}) do
    {:ok, %{package | repo: github_link(package)}}
  end

  def update_maintainer({:error, package}), do: {:error, package}

  def update_maintainer({:ok, package}) do
    {:ok, %{package | maintainers: Map.merge(owners(package), maintainers(package))}}
  end

  def update_dependencies({:error, package}), do: {:error, package}

  def update_dependencies({:ok, package}) do
    {:ok, %{package | dependencies: dependencies(package)}}
  end

  def clear_response({:error, package}), do: {:error, package.response}
  def clear_response({:ok, package}), do: {:ok, %{package | response: nil}}

  defp matching_release(package) do
    package.response["releases"]
    |> Enum.filter(fn release ->
      Version.match?(release["version"], package.version)
    end)
    |> Enum.sort(fn a, b ->
      Version.compare(a["version"], b["version"]) == :gt
    end)
    |> List.first()
  end

  def github_link(package) do
    package.response["meta"]["links"]
    |> Enum.map(fn {k, v} ->
      case String.downcase(k) do
        "github" -> v
        _ -> nil
      end
    end)
    |> Enum.filter(& &1)
    |> List.first()
  end

  defp owners(package) do
    Enum.reduce(package.response["owners"], %{}, fn owner, acc ->
      Map.put(acc, owner["username"], %{email: owner["email"], url: owner["url"]})
    end)
  end

  defp maintainers(package) do
    Enum.reduce(package.response["meta"]["maintainers"], %{}, fn owner, acc ->
      Map.put(acc, owner["username"], %{email: owner["email"], url: owner["url"]})
    end)
  end

  defp dependencies(package) do
    Enum.reduce(package.response["requirements"], %{}, fn {k, v}, acc ->
      Map.put(acc, k, %{repo: "hexpm", version: v["requirement"]})
    end)
  end
end
