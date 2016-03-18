use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dev_wizard, DevWizard.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :dev_wizard, DevWizard.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "dev_wizard_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :dev_wizard, :github_api, DevWizard.GithubGateway.Memory
