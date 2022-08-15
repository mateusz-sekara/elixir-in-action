defmodule SimpleRegistry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    GenServer.call(__MODULE__, {:register, name})
  end

  def whereis(name) do
    GenServer.call(__MODULE__, {:whereis, name})
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, name}, _from, state) do
    {status, new_state} = case Map.has_key?(state, name) do
      true ->
        {:error, state}
      false ->
        {:ok, Map.put(state, name, self())}
    end
    {:reply, status, new_state}
  end

  @impl GenServer
  def handle_call({:whereis, name}, _from, state) do
    {:reply, Map.get(state, name), state}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    {:noreply, remove_process_by_pid(pid, state)}
  end

  defp remove_process_by_pid(pid, state) do
    case Enum.find(state, fn {_, value} -> value == pid end) do
      {key, _} -> Map.delete(state, key)
      _ -> state
    end
  end
end
