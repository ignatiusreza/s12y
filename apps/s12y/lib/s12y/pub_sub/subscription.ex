defmodule S12y.PubSub.Subscription do
  defmacro __using__(topic: topic) do
    quote do
      use GenServer

      import S12y.PubSub.Subscription

      # CLIENT
      def start_link(_) do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

      # SERVER

      def init(_) do
        S12y.PubSub.subscribe(unquote(topic))

        {:ok, nil}
      end

      def handle_info({event, payload}, state) do
        handle_message(event, payload)

        {:noreply, state}
      end
    end
  end
end
