defmodule S12y.PubSub.SubscriptionCase do
  defmacro __using__(topic: topic) do
    quote do
      use GenServer

      import S12y.PubSub.Subscription

      # CLIENT

      def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      def reset(), do: GenServer.call(__MODULE__, {:reset})
      def state(), do: GenServer.call(__MODULE__, {:state})

      # SERVER

      def init(_) do
        S12y.PubSub.subscribe(unquote(topic))

        {:ok, []}
      end

      def handle_call({:reset}, _from, state), do: {:reply, [], []}
      def handle_call({:state}, _from, state), do: {:reply, state, state}
      def handle_info(message, state), do: {:noreply, [message | state]}
    end
  end
end
