defmodule S12y.Repo.Migrations.AddTrackingIntoProject do
  use Ecto.Migration

  def change do
    alter table("projects") do
      add :parsed_at, :utc_datetime
      add :parse_failed_at, :utc_datetime
      add :parse_error, :text
    end
  end
end
