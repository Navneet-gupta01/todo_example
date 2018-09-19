defmodule Todo.Server do
  use GenServer

  # This is a simplistic approach that works for this case, but you should generally be careful about
  # possibly long-running init/1 callbacks. Recall that GenServer.start returns only after the process
  # has been initialized. Consequently, a long-running init/1 function will cause the creator process to block.
  # In this case, a long initialization of a to-do server will block the cache process, which is used by many clients.
  @impl GenServer
  def init(name) do
    {:ok,{name, Todo.Database.get(name) || Todo.List.new()}}
  end

  # To circumvent this problem, there’s a simple trick. You can use init/1 to send yourself an internal message
  # and then initialize the process state in the corresponding handle_info callback:
  # @impl GenServer
  # def init(name) do
  #   send(self(), :real_init)
  #   {:ok, nil}
  # end
  #
  #
  # def handle_info(:real_init, state) do
  #   ...
  # end
  # Above generally work as long as your process isn’t registered under a local name. If the process isn’t registered,
  # someone has to know its pid to send it a message, and that pid will only be known after init/1 has finished.
  # Hence, you can be sure that the message you send to yourself is the first one being handled.
  # But if the process is registered, there is a chance that someone else will put the message in their queue first by
  # referencing the process via registered name. This can happen because at the moment init/1 is invoked, the process
  # is already registered under the name (due to the inner workings of GenServer). There are a couple of workarounds
  # for this problem, the simplest one being to not use the :name option and opt instead for manual registration of the
  # process in the init/1 callback after the message to self is sent:
  # def init(params) do
  #   ...
  #   send(self(), :real_init)
  #   register(self(), :some_name)
  # end


  @impl GenServer
  def handle_call({:get, date}, _, {name,state}) do
    {
      :reply,
      Todo.List.entries(state, date),
      {name,state}
    }
  end

  @impl GenServer
  def handle_cast({:put, entry}, {name,state}) do
    new_state = Todo.List.add_entry(state, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:put, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:get, date}, 5000)
  end
end
