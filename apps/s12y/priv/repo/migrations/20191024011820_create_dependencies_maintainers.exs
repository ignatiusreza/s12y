defmodule S12y.Repo.Migrations.CreateDependenciesMaintainers do
  use Ecto.Migration

  def change do
    create table(:dependencies_maintainers) do
      add :dependency_id, references(:dependencies)
      add :maintainer_id, references(:maintainers)
    end

    create unique_index(:dependencies_maintainers, [:dependency_id, :maintainer_id])
  end
end
