defmodule Todo.DatabaseWorker do
  use GenServer

  @impl GenServer
  def init(db_folder) do
    IO.puts "init Todo.DatabaseWorker"
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, value}, db_folder) do
    db_folder
      |> file_name(key)
      |> File.write!(:erlang.term_to_binary(value))
      {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    binary_value =
       db_folder
       |> file_name(key)
       |> File.read()

    value = case binary_value do
      {:ok, contents} -> :erlang.binary_to_term(contents)
       _ -> nil
    end
    {:reply, value, db_folder}
  end

  def start_link({db_folder,worker_id}) do
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id) )
  end

  def store(worker_id, key, value) do
     GenServer.cast(via_tuple(worker_id), {:store, key, value})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  defp file_name(db_folder, key) do
      Path.join(db_folder, to_string(key))
  end

  defp via_tuple(worker_id) do
    ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
