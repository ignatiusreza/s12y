defmodule S12y.Repo.Migrations.CreateDependenciesDependencies do
  use Ecto.Migration

  def change do
    create table(:dependencies_dependencies) do
      add :parent_id, references(:dependencies)
      add :child_id, references(:dependencies)
    end

    create unique_index(:dependencies_dependencies, [:parent_id, :child_id])
  end
end
