import Config

# Configure your database
config :s12y, S12y.Repo,
  username: "postgres",
  password: "postgres",
  database: "s12y_test",
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  port: System.get_env("POSTGRES_PORT", "5432"),
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn
