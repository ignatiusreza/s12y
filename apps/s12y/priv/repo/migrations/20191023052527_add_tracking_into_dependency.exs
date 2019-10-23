defmodule S12y.Repo.Migrations.AddTrackingIntoDependency do
  use Ecto.Migration

  def change do
    alter table("dependencies") do
      add :lookup_at, :utc_datetime
      add :lookup_failed_at, :utc_datetime
      add :lookup_error, :text
    end
  end
end
