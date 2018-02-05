defmodule GN.Orchestration do
  import GN.Gluon

  @timeout 300000 # 5 minutes

  def pmap(collection, function) do
    collection
    |> Enum.map(&Task.async(fn -> function.(&1) end))
    |> Enum.map(&Task.await(&1, @timeout))
  end

  def start_and_spawn(seed_layers) do
    {:ok, py} = start()
    net = GN.Evolution.spawn_offspring(seed_layers, py)
    trained_net = py |> call(run(net))
    py |> call(print_net(trained_net))
  end

end
