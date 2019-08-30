defmodule S12y.Repo do
  use Ecto.Repo,
    otp_app: :s12y,
    adapter: Ecto.Adapters.Postgres
end
