defmodule S12yWeb.Schema.Resources do
  use Absinthe.Schema.Notation

  alias S12yWeb.Resolvers

  object :project do
    field :id, :id

    field :configurations, list_of(:configuration) do
      resolve &Resolvers.Project.list_configurations/3
    end
  end

  object :configuration do
    field :id, :id
    field :project_id, :id
  end
end
