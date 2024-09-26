defmodule AgentExample do
  def run do
    # Agent.start_link/1
    {:ok, agent} = Agent.start(fn -> %{count: 0} end)

    # Agent.update/3
    Agent.update(agent, fn state ->
      Map.update(state, :count, 0, &(&1 + 1))
    end)

    # Agent.get/3
    count = Agent.get(agent, fn state -> state.count end)
    IO.puts("Current count: #{count}")

    # Concurrent updates
    tasks = Enum.map(1..10, fn _ ->
      Task.async(fn ->
        Agent.update(agent, fn state ->
          Map.update(state, :count, 0, &(&1 + 1))
        end)
      end)
    end)

    Enum.each(tasks, &Task.await/1)

    final_count = Agent.get(agent, fn state -> state.count end)
    IO.puts("Final count: #{final_count}")

    # Agent.get_and_update/3
    {old_count, _} = Agent.get_and_update(agent, fn state ->
      new_state = Map.put(state, :count, 0)
      {state.count, new_state}
    end)

    IO.puts("Old count: #{old_count}")
    IO.puts("Reset count: #{Agent.get(agent, fn state -> state.count end)}")
  end
end

AgentExample.run()
