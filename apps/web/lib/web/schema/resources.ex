defmodule Web.Schema.Resources do
  use Absinthe.Schema.Notation

  alias Web.Resolvers

  object :project do
    field :id, :id

    field :configurations, list_of(:configuration) do
      resolve &Resolvers.Project.list_configurations/3
    end

    field :dependencies, list_of(:dependency) do
      resolve &Resolvers.Project.list_dependencies/3
    end

    field :maintainers, list_of(:maintainer) do
      resolve &Resolvers.Project.list_maintainers/3
    end
  end

  object :configuration do
    field :id, :id
    field :project_id, :id
  end

  object :dependency do
    field :id, :id
    field :name, :string
    field :version, :string
  end

  object :maintainer do
    field :id, :id
    field :handle, :string
    field :email, :string
  end
end
