ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(S12y.Repo, :manual)

case System.cmd("which", ["docker"]) do
  {_, 0} ->
    :ok

  _ ->
    ExUnit.configure(exclude: [docker: true])
end
