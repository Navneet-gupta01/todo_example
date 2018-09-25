defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  @impl GenServer
  def init(_) do
    IO.puts "init Todo.Database"
    File.mkdir(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end

  def start_workers() do
    for index <- 1..3, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {index - 1, pid}
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end
  
  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key}, 5000)
  end

  def child_spec(_) do
    File.mkdir_p!(@db_folder)
    :poolboy.child_spec(
        __MODULE__,
        [
          name: {:local, __MODULE__},
          worker_module: Todo.DatabaseWorker,
          size: 3
        ],
      [@db_folder]
    )
  end
end
