defmodule S12y.Fixture do
  alias S12y.Project

  defmacro valid_project_attrs do
    fixture = read_fixture!("parsers/mix/mix_new/input")

    quote do
      %{configurations: [%{filename: "mix.exs", content: unquote(fixture)}]}
    end
  end

  @fixtures_path Path.expand("../../../../fixtures", __DIR__)
  def read_fixture!(path) do
    path
    |> Path.expand(@fixtures_path)
    |> File.read!()
  end

  def project_fixture(attrs \\ valid_project_attrs()) do
    {:ok, project} =
      attrs
      |> Enum.into(attrs)
      |> Project.create_project()

    project
  end
end
