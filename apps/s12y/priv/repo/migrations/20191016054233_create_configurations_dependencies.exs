defmodule S12y.Repo.Migrations.CreateConfigurationsDependencies do
  use Ecto.Migration

  def change do
    create table(:configurations_dependencies) do
      add :configuration_id, references(:configurations)
      add :dependency_id, references(:dependencies)
    end

    create unique_index(:configurations_dependencies, [:configuration_id, :dependency_id])
  end
end
