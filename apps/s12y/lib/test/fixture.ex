defmodule S12y.Fixture do
  alias S12y.Project

  defmacro valid_project_attrs do
    fixture = read_fixture!("parsers/mix/mix_new/input")

    quote do
      %{configurations: [%{filename: "mix.exs", content: unquote(fixture)}]}
    end
  end

  defmacro valid_dependencies_attrs do
    quote do
      %{"phoenix" => %{"repo" => "hexpm", "version" => "~> 1.4.9"}}
    end
  end

  defmacro valid_nested_dependencies_attrs do
    quote do
      %{
        "plug" => %{"repo" => "hexpm", "version" => "~> 1.8.1 or ~> 1.9"},
        "plug_cowboy" => %{"repo" => "hexpm", "version" => "~> 1.0 or ~> 2.0"}
      }
    end
  end

  defmacro malformed_project_attrs do
    fixture = read_fixture!("parsers/mix/malformed/input")

    quote do
      %{configurations: [%{filename: "mix.exs", content: unquote(fixture)}]}
    end
  end

  defmacro unknown_dependency_attrs do
    quote do
      # Let's pray nobody publish this package :grin:
      %{"unknown" => %{"repo" => "hexpm", "version" => "~> 0.0.1"}}
    end
  end

  @fixtures_path Path.expand("../../../../fixtures", __DIR__)
  def fixture_path(path), do: Path.expand(path, @fixtures_path)

  def read_fixture!(path) do
    path
    |> fixture_path
    |> File.read!()
  end

  def project_fixture(attrs \\ valid_project_attrs()) do
    {:ok, project} =
      attrs
      |> Enum.into(attrs)
      |> Project.create_project()

    project
  end

  def configuration_fixture() do
    project = project_fixture()

    configuration =
      project.configurations
      |> List.first()
      |> (&Project.get_configuration(&1.id)).()

    {:ok, %{project: project, configuration: configuration}}
  end

  def dependency_fixture(attrs \\ valid_dependencies_attrs()) do
    with {:ok, %{project: project, configuration: configuration}} <- configuration_fixture(),
         {:ok, configuration} <- Project.add_dependencies(configuration, attrs),
         dependency <- List.first(configuration.dependencies) do
      {:ok, %{project: project, configuration: configuration, dependency: dependency}}
    end
  end
end
