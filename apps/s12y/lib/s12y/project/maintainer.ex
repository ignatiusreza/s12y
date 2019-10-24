defmodule S12y.Project.Maintainer do
  use Ecto.Schema
  import Ecto.Changeset

  alias S12y.Project

  @required_fields ~w(handle)a
  @optional_fields ~w(email)a

  schema "maintainers" do
    many_to_many :dependencies, Project.Dependency, join_through: "dependencies_maintainers"

    field :handle, :string
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(maintainer, attrs) do
    maintainer
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
