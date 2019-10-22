defmodule S12y.Registries.Worker.Subscription do
  use S12y.PubSub.Subscription, topic: "dependency"

  alias S12y.Registries
  alias S12y.Project

  # CRUD
  def handle_message(:created, %Project.Dependency{} = dependency) do
    Registries.Worker.lookup(dependency)
  end

  # Parsing

  def handle_message(:lookup, {%Project.Dependency{} = dependency, details}) do
  end

  def handle_message(:lookup_failed, {%Project.Dependency{} = dependency, {error, _}})
      when is_bitstring(error) do
  end
end
