# Start an Agent
iex> {:ok, agent} = Agent.start_link(fn -> %{temperature: 20.0} end)

# Get state
iex> Agent.get(agent, fn state -> state end)

# Update state
iex> Agent.update(agent, fn state -> Map.put(state, :humidity, 60) end)
iex> Agent.get(agent, & &1)

# Get and update atomically
iex> Agent.get_and_update(agent, fn state ->
...>   {state.temperature, %{state | temperature: state.temperature + 0.5}}
...> end)

# Cast (async update)
iex> Agent.cast(agent, fn state -> Map.put(state, :async_key, "async value") end)
iex> Agent.get(agent, & &1)

# Start with name
iex> {:ok, _} = Agent.start_link(fn -> %{} end, name: :named_agent)
iex> Agent.update(:named_agent, fn state -> Map.put(state, :key, "value") end)
iex> Agent.get(:named_agent, & &1)

# Use in multiple processes
iex> task = Task.async(fn ->
...>   Agent.update(agent, fn state -> Map.put(state, :from_task, "task value") end)
...> end)
iex> Task.await(task)
iex> Agent.get(agent, & &1)

# Error handling
iex> try do
...>   Agent.get(agent, fn _ -> raise "Oops" end)
...> rescue
...>   e in RuntimeError ->
...>     IO.puts("Error occurred: #{e.message}")
...>     :error
...> end

# Stopping an agent
iex> Agent.stop(agent)
iex> Process.alive?(agent)

# Custom timeout
iex> {:ok, slow_agent} = Agent.start_link(fn ->
...>   :timer.sleep(5000)
...>   %{slow: true}
...> end)
iex> Agent.get(slow_agent, & &1, 6000)
