defmodule S12y.Registries.Worker do
  alias S12y.Registries.Worker

  def lookup(project) do
    Worker.Runtime.lookup(project)
  end
end
