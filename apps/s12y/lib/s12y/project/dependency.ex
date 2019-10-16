defmodule S12y.Project.Dependency do
  use Ecto.Schema
  import Ecto.Changeset

  alias S12y.Project

  @required_fields ~w(name repo version)a
  @optional_fields ~w()a

  schema "dependencies" do
    many_to_many :configurations, Project.Configuration,
      join_through: "configurations_dependencies"

    field :name, :string
    field :repo, :string
    field :version, :string

    timestamps()
  end

  @doc false
  def changeset(dependency, attrs) do
    dependency
    |> cast(attrs, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end
end
