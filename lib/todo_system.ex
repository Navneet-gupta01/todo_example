defmodule TodoSystem do
  def start_link do
    Supervisor.start_link(
      [Todo.Cache],
      strategy: :one_for_one
      )
  end
end

# Either of the TodoSystem or TodoSupervisor can be used to supervise the cache process.
# But TodoSupervisor uses callback of Supervisor which is helpful for hot code reloading and maintainance
