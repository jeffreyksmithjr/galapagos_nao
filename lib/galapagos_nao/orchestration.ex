defmodule GN.Orchestration do
  import GN.Gluon
  import GN.Evolution, only: [spawn_offspring: 1, build_layer: 2]
  alias GN.Network, as: Network
  import GN.Selection, only: [select: 1]

  def start_and_spawn({_level, net}) do
    seed_layers = net.layers
    layers = spawn_offspring(seed_layers)

    {:ok, py} = start()
    built_layers = Enum.map(layers, &build_layer(&1, py))
    built_net = py |> call(build(built_layers))
    test_acc = py |> call(run(built_net))

    %Network{layers: layers, test_acc: test_acc}
  end

  def learn_generation(%Network{} = initial_net) do
    generation_size = GN.Parameters.get(__MODULE__, :generation_size)
    # clone the initial net to create a generation
    nets =
      Enum.reduce(1..generation_size, %{}, fn n, acc ->
        Map.put(acc, -1 * n, initial_net)
      end)

    learn_generation(nets)
  end

  def learn_generation(nets) when map_size(nets) == 1 do
    # too little diversity in complexity, so clones must be spawned
    [net] = Map.values(nets)
    learn_generation(net)
  end

  def learn_generation(nets) do
    tasks =
      Task.Supervisor.async_stream_nolink(
        GN.TaskSupervisor,
        nets,
        &start_and_spawn(&1),
        timeout: GN.Parameters.get(__MODULE__, :timeout)
      )

    generation = for {status, net} <- tasks, status == :ok, do: net
    IO.puts(inspect(generation))
    generation
  end

  def evolve(nets, generations) when generations > 0 do
    IO.puts("Generations remaining: #{generations}")

    learn_generation(nets)
    |> select()
    |> evolve(generations - 1)
  end

  def evolve(nets, _generations) do
    nets
  end
end
