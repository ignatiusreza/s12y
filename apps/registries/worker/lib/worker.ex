defmodule S12y.Registries.Worker do
  alias S12y.Registries.Worker

  def parse(project) do
    Worker.Runtime.parse(project)
  end
end
