defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_processes" do
    {:ok,cache} = Todo.Cache.start
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "todo-Operations" do
    {:ok, cache} = Todo.Cache.start
    bob_pid =  Todo.Cache.server_process(cache, "bob")
    Todo.Server.addItem(bob_pid, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(bob_pid, ~D[2018-12-19])
    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end

end
