defmodule TaskExample do
  def run do
    # Task.async/1
    task1 = Task.async(fn -> heavy_computation(1) end)
    task2 = Task.async(fn -> heavy_computation(5) end)

    # Do other work here
    IO.puts("Doing other work while tasks are running...")

    # Task.await/1
    result1 = Task.await(task1)
    IO.puts("Result 1: #{result1}")

    # Task.yield/2 with timeout
    case Task.yield(task2, 3000) do
      {:ok, result} -> IO.puts("Result 2: #{result}")
      nil ->
        IO.puts("Task 2 didn't finish in time")
        Task.shutdown(task2)
    end

    # Task.start/1 for fire-and-forget
    Task.start(fn ->
      send(self(), {:background_task_done, heavy_computation(3)})
    end)

    receive do
      {:background_task_done, result} -> IO.puts("Background task result: #{result}")
    after
      3000 -> IO.puts("Background task running...")
    end
  end

  defp heavy_computation(n) do
    Process.sleep(1000 *n)
    n * 2
  end

  defmodule TaskDemo do
    def run do
      task = Task.async(fn ->
        IO.puts("Task is running")
        Process.sleep(2000)
        IO.puts("Task is done")
        42
      end)

      IO.puts("Main process continues...")
      Process.sleep(3000)
      IO.puts("Main process done")

      # We're not calling Task.await(task) here
    end
  end
end

# TaskExample.run()
# TaskExample.TaskDemo.run()
