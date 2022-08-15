defmodule QueueTest do
  use ExUnit.Case

  describe "Queue.Server" do
    setup %{module: module, test: test} do
      queue_name = Module.concat([module, test, Queue])

      child_spec = %{
        id: Queue.Server,
        restart: :transient,
        start: {
          Queue.Server,
          :start_link,
          [[], queue_name]
        }
      }

      {:ok, queue_pid} = start_supervised(child_spec)

      %{
        queue_pid: queue_pid,
        queue_name: queue_name
      }
    end

    test "should return elements properly", %{queue_name: queue_name} do
      Queue.Server.push(queue_name, 2)
      Queue.Server.push(queue_name, 1)

      assert Queue.Server.pop(queue_name) == 2
      assert Queue.Server.len(queue_name) == 1
    end
  end
end
