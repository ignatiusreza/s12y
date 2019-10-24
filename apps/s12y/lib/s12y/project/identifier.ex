defmodule S12y.Project.Identifier do
  use Ecto.Schema
  import Ecto.Changeset

  alias S12y.Project.Configuration

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields ~w()a
  @optional_fields ~w()a

  schema "projects" do
    has_many :configurations, Configuration, foreign_key: :project_id

    field :parsed_at, :utc_datetime
    field :parse_failed_at, :utc_datetime
    field :parse_error, :string

    timestamps()
  end

  @doc false
  def changeset(identifier, attrs) do
    identifier
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:configurations, required: true)
  end
end
