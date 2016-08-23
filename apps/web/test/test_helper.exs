ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Web.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Web.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Web.Repo)

