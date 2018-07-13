Aprb.Repo.start_link()
Application.ensure_all_started(:ex_machina)
Application.ensure_all_started(:calendar)
Application.ensure_all_started(:plug)
Logger.configure(level: :error)
ExUnit.configure seed: elem(:os.timestamp, 2)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, {:shared, self()})
