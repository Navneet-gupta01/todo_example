defmodule LoadTest do
  @total_processes 1_000_000
  @interval_size 100_000

  def run do
    {:ok, cache} = Todo.Cache.start()

    interval_count = round(@total_processes / @interval_size)
    Enum.each(0..(interval_count - 1), &run_interval(make_interval(&1)))
  end

  defp make_interval(n) do
    start = n * @interval_size
    start..(start + @interval_size - 1)
  end

  defp run_interval(interval) do
    {time, _} =
      :timer.tc(fn ->
        interval
        |> Enum.each(&Todo.Cache.server_process("cache_#{&1}"))
      end)

    IO.puts("#{inspect(interval)}: average put #{time / @interval_size} μs")

    {time, _} =
      :timer.tc(fn ->
        interval
        |> Enum.each(&Todo.Cache.server_process("cache_#{&1}"))
      end)

    IO.puts("#{inspect(interval)}: average get #{time / @interval_size} μs\n")
  end
end
