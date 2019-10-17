defmodule S12y.Project do
  import Ecto.Query, warn: false

  alias S12y.Project
  alias S12y.PubSub.Broadcast
  alias S12y.Repo

  ### PROJECT

  @doc """
  Lookup a single project by id (uuid)
  """
  def get_project(id) do
    Project.Identifier
    |> Repo.get(id)
    |> Repo.preload(:configurations)
  end

  @doc """
  Creates a project.
  """
  def create_project(attrs) do
    %Project.Identifier{}
    |> Project.Identifier.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  defp broadcast({:ok, project} = passthrough, action) do
    Broadcast.project(action, project)

    passthrough
  end

  defp broadcast({:error, %Ecto.Changeset{}} = passthrough, _), do: passthrough
end
