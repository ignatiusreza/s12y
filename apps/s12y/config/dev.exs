import Config

# Configure your database
config :s12y, S12y.Repo,
  username: "postgres",
  password: "postgres",
  database: "s12y_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
