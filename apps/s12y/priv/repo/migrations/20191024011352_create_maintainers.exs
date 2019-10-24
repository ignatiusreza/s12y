defmodule S12y.Repo.Migrations.CreateMaintainers do
  use Ecto.Migration

  def change do
    create table(:maintainers) do
      add :handle, :string
      add :email, :string

      timestamps()
    end

    create unique_index(:maintainers, [:handle, :email])
  end
end
