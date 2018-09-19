defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_processes" do
    {:ok,_cache} = Todo.Cache.start
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "todo-Operations" do
    {:ok, _cache} = Todo.Cache.start
    bob_pid =  Todo.Cache.server_process("bob")
    Todo.Server.addItem(bob_pid, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(bob_pid, ~D[2018-12-19])
    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end

end
