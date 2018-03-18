defmodule GN.Selection do
  use Agent

  def select(nets) do
    cutoffs = cutoffs(nets)

    for net <- nets do
      complexity = length(net.layers)
      level = Enum.min([Enum.find_index(cutoffs, &(&1 >= complexity)) + 1, complexity_levels()])
      net_acc = net.test_acc
      elite_acc = Map.get(get(level), :test_acc)

      if is_nil(elite_acc) or net_acc > elite_acc do
        put(level, net)
      end
    end

    get_all()
  end

  def cutoffs(nets) do
    max_complexity =
      Enum.map(nets, &length(Map.get(&1, :layers)))
      |> Enum.max()

    interval = max_complexity / complexity_levels()

    for level <- 1..complexity_levels() do
      interval * level
    end
  end

  def complexity_levels do
    GN.Parameters.get(__MODULE__, :complexity_levels)
  end

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key, %{}))
  end

  def get_all() do
    Agent.get(__MODULE__, & &1)
  end
end
