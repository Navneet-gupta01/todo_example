defmodule Todo.Cache do
  use GenServer


  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_processes, todo_name}, _, state) do
    case Map.fetch(state, todo_name) do
      :error ->
        {:ok, server_process} = Todo.Server.start(todo_name)
        {:reply, server_process, Map.put(state, todo_name, server_process)}
      {:ok, server_process} ->
        {:reply, server_process, state}
    end
  end

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_name) do
    GenServer.call(__MODULE__,{:server_processes, todo_name}, 5000)
  end
end
