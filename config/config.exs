# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :dev_wizard, DevWizard.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "f3ZdnpibliGfdxmNy0xLMZk2NNHsgYoQeCj1sVlFq92Lv4ZnnvGlCYjznts+fhdN",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: DevWizard.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :dev_wizard, :github_settings,
  repositories:    (System.get_env("DW_GH_REPOSITORIES") || "") |> String.strip |> String.split(","),
  storyboard_repo: String.strip(System.get_env("DW_GH_STORYBOARD_REPO") || ""),
  organization:    String.strip(System.get_env("DW_GH_ORGANIZATION") || ""),
  client_id:       String.strip(System.get_env("DW_GH_CLIENT_ID") || ""),
  client_secret:   String.strip(System.get_env("DW_GH_CLIENT_SECRET") || ""),
  callback_uri:    String.strip(System.get_env("DW_GH_CALLBACK_URL") || "")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Custom header for Github Reviews API
config :tentacat, :extra_headers, [{"Accept", "application/vnd.github.black-cat-preview+json"}]
