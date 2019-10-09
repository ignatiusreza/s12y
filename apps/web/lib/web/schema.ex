defmodule Web.Schema do
  use Absinthe.Schema
  alias Web.Resolvers

  import_types Web.Schema.Resources
  import_types Web.Schema.Mutations

  query do
    @desc "Lookup a single project by id (uuid)"
    field :project, :project do
      arg :id, non_null(:id)
      resolve &Resolvers.Project.get_project/3
    end
  end

  mutation do
    @desc "Create a project"
    field :create_project, type: :project do
      arg :configurations, list_of(:configuration_input)

      resolve &Resolvers.Project.create_project/3
    end
  end
end
