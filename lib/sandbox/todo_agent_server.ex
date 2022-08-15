defmodule Sandbox.TodoAgentServer do
  use Agent, restart: :temporary

  def start_link(todo_list_name) do
    Agent.start_link(
      init(todo_list_name),
      name: via_tuple(todo_list_name)
    )
  end

  def add_entry(todo_server, entry) do
    Agent.cast(
      todo_server,
      fn {list_name, list} ->
        new_list = Todo.List.add_entry(list, entry)
        Todo.Database.store(list_name, new_list)
        {list_name, new_list}
      end
    )
  end

  def update_entry(todo_server, new_entry) do
    Agent.cast(
      todo_server,
      fn {list_name, list} ->
        new_list = Todo.List.update_entry(list, new_entry)
        Todo.Database.store(list_name, new_list)
        {list_name, new_list}
      end
    )
  end

  def entries(todo_server, date) do
    Agent.get(
      todo_server,
      fn {_name, list} -> Todo.List.entries(list, date) end
    )
  end

  defp init(todo_list_name) do
    fn ->
      IO.puts("Starting to-do server")
      database = Todo.Database.get(todo_list_name) || Todo.List.new()
      {todo_list_name, database}
    end
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
