defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")
    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "todo operations" do
    john_pid = Todo.Cache.server_process("john")

    Todo.Server.add_entry(john_pid,  %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(john_pid, ~D[2018-12-19])

    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end
end
