defmodule S12yWeb.Schema.Mutations do
  use Absinthe.Schema.Notation

  import_types Absinthe.Plug.Types

  input_object :configuration_input do
    field :filename, non_null(:string)
    field :content, non_null(:upload)
  end
end
