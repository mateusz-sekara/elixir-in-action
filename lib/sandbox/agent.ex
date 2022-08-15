defmodule Sandbox.Agent do
  use GenServer

  def start_link(init_fun) do
    GenServer.start_link(__MODULE__, init_fun)
  end

  def get(pid, fun) do
    GenServer.call(pid, {:get, fun})
  end

  def update(pid, fun) do
    GenServer.call(pid, {:update, fun})
  end

  @impl GenServer
  def init(init_fun) do
      {:ok, init_fun.()}
  end

  @impl GenServer
  def handle_call({:get, fun}, _, state) do
    result = fun.(state)
    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:update, fun}, _, state) do
    new_state = fun.(state)
    {:reply, :ok, new_state}
  end
end
