# Basic Task.async and Task.await
iex> task = Task.async(fn -> :timer.sleep(2000); "Done sleeping" end)
iex> Task.await(task)

# Multiple tasks
iex> tasks = Enum.map(1..3, fn i -> Task.async(fn -> :timer.sleep(1000 * i); "Task #{i} done" end) end)
iex> Enum.map(tasks, &Task.await/1)

# Task.yield with timeout
iex> task = Task.async(fn -> :timer.sleep(3000); "Slow task done" end)
iex> Task.yield(task, 2000)
iex> Task.yield(task, 2000)

# Task.start (fire-and-forget)
iex> Task.start(fn -> IO.puts("Background task running"); :timer.sleep(2000); IO.puts("Background task done") end)

# Task.async_stream
# This Task.async_stream processes each element in 1..5 concurrently.
# It applies the given function to each element, which sleeps for 1 second and then squares the number.
# The stream is then collected into a list. Each task has a default timeout of 5000ms.
# The difference between a stream and a list:
# A stream is lazy and processes elements on-demand, while a list is eager and contains all elements in memory.
# Streams are more memory-efficient for large datasets or infinite sequences.
# If we don't pass the result of Task.async_stream to Enum.to_list() or another
# enumerable function, the actions won't take place due to its lazy behavior.
# The stream needs to be consumed for the tasks to actually run.
iex> Task.async_stream(1..5, fn i -> :timer.sleep(1000); i * i end) |> Enum.to_list()

# Error handling
iex> task = Task.async(fn ->
...>   try do
...>     # Simulating some work that might raise an error
...>     if :rand.uniform() > 0.5, do: raise("Oops"), else: "Success"
    # rescue catches specific exceptions. It's followed by pattern matching clauses.
    # Each clause matches an exception type and binds the error to a variable.
    # The code after '->' is executed if the exception matches.
    # rescue prevents the process from shutting down by handling the exception,
    # allowing the code to continue execution or return a controlled error value.
...>   rescue
...>     e in RuntimeError -> {:error, e.message}
...>   end
...> end)
iex> case Task.await(task) do
...>   {:error, message} -> IO.puts("Task failed: #{message}")
...>   result -> IO.puts("Task succeeded: #{result}")
...> end

# Task.shutdown
iex> task = Task.async(fn -> :timer.sleep(10000); "Won't finish" end)
iex> Task.shutdown(task, :brutal_kill)
