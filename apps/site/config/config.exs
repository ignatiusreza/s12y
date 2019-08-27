# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :site,
  ecto_repos: [Site.Repo]

# Configures the endpoint
config :site, SiteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4Z+v+ggjkQPB+vQAiWXYetyCyXyTCE2Yt+3+/+OqA3GjKfrCBJ+U5h1vdE9r3y39",
  render_errors: [view: SiteWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Site.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
