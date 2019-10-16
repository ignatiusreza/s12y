defmodule S12y.Project.Configuration do
  use Ecto.Schema
  import Ecto.Changeset

  alias S12y.Project

  @required_fields ~w(parser filename content)a
  @optional_fields ~w()a

  schema "configurations" do
    belongs_to :project, Project.Identifier, type: :binary_id
    many_to_many :dependencies, Project.Dependency, join_through: "configurations_dependencies"

    field :parser, :string
    field :filename, :string
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(configuration, attrs) do
    configuration
    |> cast(attrs, @required_fields, @optional_fields)
    |> cast_parser
    |> validate_required(@required_fields)
  end

  @doc false
  defp cast_parser(changeset) do
    case changeset.changes do
      %{filename: filename} ->
        case filename do
          "mix.exs" -> put_change(changeset, :parser, "mix")
          _ -> changeset
        end

      _ ->
        changeset
    end
  end
end
