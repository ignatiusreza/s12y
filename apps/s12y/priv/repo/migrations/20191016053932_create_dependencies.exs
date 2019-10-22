defmodule S12y.Repo.Migrations.CreateDependencies do
  use Ecto.Migration

  def change do
    create table(:dependencies) do
      add :repo, :string
      add :name, :string
      add :version, :string

      timestamps()
    end

    create unique_index(:dependencies, [:repo, :name, :version])
  end
end
