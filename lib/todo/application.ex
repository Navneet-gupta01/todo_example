defmodule Todo.Application do
  use Application

  def start(_, _) do
    TodoSupervisor.start_link()
  end
end
