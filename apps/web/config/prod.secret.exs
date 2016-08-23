use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :web, Web.Endpoint,
  secret_key_base: "UI6e272It+HUz5qB0Mq3YfesU5abjyfYW8vtyJQqXHY/wrMvYtCPGnLa4mmcpcr3"

# Configure your database
config :web, Web.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "elixir_ai_web_prod",
  pool_size: 20
