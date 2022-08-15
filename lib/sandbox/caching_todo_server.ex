defmodule Sandbox.CachingTodoServer do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(todo_list_name) do
    IO.puts("Starting to-do server")
    GenServer.start_link(__MODULE__, todo_list_name, name: via_tuple(todo_list_name))
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @impl GenServer
  def init(todo_list_name) do
    database = Todo.Database.get(todo_list_name) || Todo.List.new()
    {
      :ok,
      {todo_list_name, database},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {list_name, list}) do
    new_list = Todo.List.add_entry(list, entry)
    Todo.Database.store(list_name, new_list)
    {
      :noreply,
      {list_name, new_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state = {_, list}) do
    {
      :reply,
      Todo.List.entries(list, date),
      state,
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_info(:timeout, state = {name, _}) do
    IO.puts("Stopping todo server for #{name}")
    {:stop, :normal, state}
  end
end
