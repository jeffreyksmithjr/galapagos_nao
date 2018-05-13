defmodule GN.Selection do
  use Agent

  def select(pid \\ __MODULE__, nets) do
    cutoffs = cutoffs(nets)

    for net <- nets do
      complexity = length(net.onnx.graph.node)
      level = Enum.min([Enum.find_index(cutoffs, &(&1 >= complexity)) + 1, complexity_levels()])
      net_acc = net.test_acc
      elite_acc = Map.get(get(level), :test_acc)

      if is_nil(elite_acc) or net_acc > elite_acc do
        put(pid, level, net)
      end
    end

    get_all(pid)
  end

  def cutoffs(nets) do
    max_complexity =
      Enum.map(nets, &length(&1.onnx.graph.node))
      |> Enum.max()

    interval = max_complexity / complexity_levels()

    for level <- 1..complexity_levels() do
      interval * level
    end
  end

  def complexity_levels do
    GN.Parameters.get(__MODULE__, :complexity_levels)
  end

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, opts)
  end

  def put_unevaluated(pid \\ __MODULE__, net) do
    new_id = (get_all(pid) |> Map.keys() |> Enum.min(fn -> 0 end)) - 1
    put(pid, new_id, net)
  end

  def put(pid \\ __MODULE__, key, net) do
    Agent.update(pid, &Map.put(&1, key, net))
  end

  def get(pid \\ __MODULE__, key) do
    Agent.get(pid, &Map.get(&1, key, %{}))
  end

  def get_all(pid \\ __MODULE__) do
    Agent.get(pid, & &1)
  end
end
