defmodule S12y.Parsers.Worker.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias S12y.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import S12y.Parsers.Worker.TestCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(S12y.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(S12y.Repo, {:shared, self()})
    end

    :ok
  end
end
