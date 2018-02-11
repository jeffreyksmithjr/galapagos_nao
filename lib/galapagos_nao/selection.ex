defmodule GN.Selection do
  use Agent

  @complexity_levels 2

  def select(nets) do
    cutoffs = cutoffs(nets)

    for net <- nets do
      complexity = length(net.layers)
      level = Enum.min([Enum.find_index(cutoffs, &(&1 >= complexity)) + 1, @complexity_levels])
      net_acc = net.test_acc
      elite_acc = Map.get(get(__MODULE__, level), :test_acc)

      if is_nil(elite_acc) or net_acc > elite_acc do
        put(__MODULE__, level, net)
      end
    end

    get_all(__MODULE__)
  end

  def cutoffs(nets) do
    max_complexity =
      Enum.map(nets, &length(Map.get(&1, :layers)))
      |> Enum.max()

    interval = max_complexity / @complexity_levels

    for level <- 1..@complexity_levels do
      interval * level
    end
  end

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key, %{}))
  end

  def get_all(pid) do
    Agent.get(pid, & &1)
  end
end
