defmodule S12y.Parsers.Worker do
  alias S12y.Parsers.Worker

  def parse(project) do
    Worker.Runtime.parse(project)
  end
end
