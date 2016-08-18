ExUnit.start()
Aprb.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, :auto)
Application.ensure_all_started(:ex_machina)
