defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker_id, key, data) do
    GenServer.cast(worker_id, {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(worker_id, {:get, key})
  end

  @impl GenServer
  def init(directory) do
    {:ok, directory}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, directory) do
    IO.inspect "#{inspect(self())}: storing #{inspect(key)}"

    directory
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, directory}
  end

  @impl GenServer
  def handle_call({:get, key}, _, directory) do
    IO.inspect "#{inspect(self())}: getting #{inspect(key)}"

    data = case File.read(file_name(directory, key)) do
      {:ok, content} -> :erlang.binary_to_term(content)
      _ -> nil
    end

    {:reply, data, directory}
  end

  defp file_name(directory, key) do
    Path.join(directory, to_string(key))
  end
end
