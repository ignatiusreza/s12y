defmodule S12y.Repo.Migrations.CreateConfigurations do
  use Ecto.Migration

  def change do
    create table(:configurations) do
      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all)
      add :parser, :string
      add :filename, :string
      add :content, :text

      timestamps()
    end

    create index(:configurations, [:project_id])
  end
end
