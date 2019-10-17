defmodule S12y.PubSub do
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, topic)
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, message)
  end

  # Helper module, shorthand for broadcast/2
  defmodule __MODULE__.Broadcast do
    alias S12y.PubSub

    def project(event, payload) when is_atom(event),
      do: PubSub.broadcast("project", {event, payload})
  end
end
