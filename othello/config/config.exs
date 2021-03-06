# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :othello,
  ecto_repos: [Othello.Repo]

# Configures the endpoint
config :othello, OthelloWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sNsDoL1Ah6YWVCZQpUrCLyNaeoXJRqKXBDb5ujEltxlLM+lutKzeqE8Ep3ep8Avz",
  render_errors: [view: OthelloWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Othello.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
