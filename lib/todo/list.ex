defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )
    %Todo.List{todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @spec update_entry(atom | %{:entries => map, optional(any) => any}, any, any) ::
          atom | %{:entries => map, optional(any) => any}
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, entry_id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{id: id, date: _, title: _} = new_entry) do
    update_entry(todo_list, id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %Todo.List{todo_list | entries: new_entries}
  end
end

defmodule TodoList.CsvImporter do
  def import(path) do
    path
    |> File.stream!
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&extract_to_tuple/1)
    |> Stream.map(&to_map/1)
    |> Enum.to_list()
    |> Todo.List.new()
  end

  defp extract_to_tuple([string_date, title]) do
    date =
      String.split(string_date, "/")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    {date, title}
  end

  defp to_map({{year, month, day}, title}) do
    {:ok, date} = Date.new(year, month, day)
    %{date: date, title: title}
  end
end

defimpl String.Chars, for: Todo.List do
  def to_string(_) do
    "#TodoList"
  end
end

defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todo.List.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list

  defp into_callback(_todo_list, :halt), do: :ok
end
