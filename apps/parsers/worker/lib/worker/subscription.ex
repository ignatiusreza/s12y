defmodule S12y.Parsers.Worker.Subscription do
  use S12y.PubSub.Subscription, topic: "project"

  alias S12y.Parsers
  alias S12y.Project

  # CRUD
  def handle_message(:created, %Project.Identifier{} = project) do
    Parsers.Worker.parse(project)
  end

  # Parsing

  def handle_message(:parsed, {%Project.Identifier{} = project, parsed}) do
    # TODO: save parsed result to database
  end

  def handle_message(:parse_failed, {%Project.Identifier{} = project, error}) do
    # TODO: mark project as failed to be parsed?
  end
end
