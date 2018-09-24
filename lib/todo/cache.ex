defmodule Todo.Cache do
  use GenServer


  @impl GenServer
  def init(_) do
    IO.puts "init Todo.Cache"
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_processes, todo_name}, _, state) do
    IO.puts "Server_process handle_Call for #{todo_name}"
    case Map.fetch(state, todo_name) do
      :error ->
        {:ok, server_process} = Todo.Server.start_link(todo_name)
        {:reply, server_process, Map.put(state, todo_name, server_process)}
      {:ok, server_process} ->
        {:reply, server_process, state}
    end
  end

  # need one arg since options will be passed from Supervisor for any initialization
  def start_link() do
    # GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}  # will lead to the invocation of Todo.Server.start_link(todo_list_name)
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end


  def server_process(todo_name) do
    IO.puts "Server_process for #{todo_name}"
    # GenServer.call(__MODULE__,{:server_processes, todo_name}, 5000)
    case start_child(todo_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end


# :erlang.system_info(:process_count)
# {:ok, cahce} = Todo.Cache.start()
# bob_list = Todo.Cache.server_process("bob_list")
# Todo.Server.entries(bob_list, ~D[2018-12-19])
# Todo.Server.add_entry(bob_list, %{date: ~D[2018-12-19], title: "Dentist"})
# Todo.Server.add_entry(bob_list, %{date: ~D[2018-12-19], title: "Medical"})
# Todo.Server.add_entry(bob_list, %{date: ~D[2018-12-19], title: "Shoppping"})
# Todo.Server.add_entry(bob_list, %{date: ~D[2018-12-20], title: "Movies"})
# Todo.Server.entries(bob_list, ~D[2018-12-19])
# Todo.Server.entries(bob_list, ~D[2018-12-20])
# Kill the process and restart
# {:ok, cahce} = Todo.Cache.start()
# bob_list = Todo.Cache.server_process("bob_list")
# Todo.Server.entries(bob_list, ~D[2018-12-19])  -- this should return the proper response read from the file
