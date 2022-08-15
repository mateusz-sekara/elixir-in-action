defmodule Queue.Server do
  use GenServer, restart: :transient

  def start_link(elements, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, elements, name: name)
  end

  def len(name \\ __MODULE__) do
    GenServer.call(name, :len)
  end

  @spec push(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def push(name \\ __MODULE__, element) do
    GenServer.cast(name, {:push, element})
  end

  def pop(name \\ __MODULE__) do
    GenServer.call(name, :pop)
  end

  def elements(name \\ __MODULE__) do
    GenServer.call(name, :elements)
  end

  @impl true
  def init(elements) do
    {
      :ok,
      %{
        queue: :queue.from_list(elements),
        len: length(elements)
      }
    }
  end

  @impl true
  def handle_call(:len, _caller, %{len: len} = state) do
    {:reply, len, state}
  end

  @impl true
  def handle_call(:pop, _caller, %{queue: queue, len: len}) do
    {element, new_queue, new_len} =
      case :queue.out(queue) do
        {:empty, q} -> {nil, q, 0}
        {{:value, value}, q} -> {value, q, len - 1}
      end

    {:reply, element, %{queue: new_queue, len: new_len}}
  end

  @impl true
  def handle_call(:elements, _caller, %{queue: queue} = state) do
    {:reply, :queue.to_list(queue), state}
  end

  @impl true
  def handle_cast({:push, element}, %{queue: queue, len: len}) do
    new_queue = :queue.in(element, queue)
    {:noreply, %{queue: new_queue, len: len + 1}}
  end
end
