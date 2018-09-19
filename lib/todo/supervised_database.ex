defmodule Todo.SupervisedDatabase do
  @db_folder "./persist"
  @pool_size 3

  def start_link() do
    IO.puts "========================Start_link 1========================"
    File.mkdir(@db_folder)
    IO.puts "========================Start_link 2========================"
    children = Enum.map(1..@pool_size, &worker_spec/1)
    IO.puts "========================Start_link 3========================"
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def worker_spec(worker_id) do
    IO.puts "========================worker_spec 1========================"
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    IO.puts "========================worker_spec 2========================"
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  # Since we are not using GenServer anymore we need to define manually child_spec/1 ,
  # Using GenServer auto define one child_spec/1
  # child_spec/1 is used by Supervisor callback to supervise the process
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # The specification contains the field :type that hasn’t been mentioned before.
  # This field can be used to indicate the type of the started process.
  # The valid values are :supervisor (if the child is a supervisor process), or :worker (for any other kind of process).
  # If you omit this field, the default value of :worker is used.

  def store(key,value) do
    choose_worker(key)
    |> Todo.DatabaseWorker.store(key, value)
  end

  def get(key) do
    choose_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
