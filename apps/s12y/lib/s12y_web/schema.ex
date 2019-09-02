defmodule S12yWeb.Schema do
  use Absinthe.Schema
  alias S12yWeb.Resolvers

  import_types S12yWeb.Schema.Resources
  import_types S12yWeb.Schema.Mutations

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
      arg :configurations, non_null(list_of(:configuration_input))

      resolve &Resolvers.Project.create_project/3
    end
  end
end
