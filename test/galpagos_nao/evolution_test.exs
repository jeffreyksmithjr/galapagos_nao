defmodule GN.EvolutionTest do
  use ExUnit.Case
  import GN.Evolution
  import GN.Gluon, only: [start: 0, activation_functions: 0]

  test "looks up defaults" do
    layer_type = :dense
    expected_defaults = [64, :none]
    assert seed_params(layer_type) == expected_defaults
  end

  test "builds a layer in Python" do
    layer_type = :dense
    params = [32, :relu]
    tagged_layer = {layer_type, params}
    {:ok, py} = start()
    assert match?({:"$erlport.opaque", :python, _}, build_layer(tagged_layer, py))
  end

  test "doesn't mutate params" do
    params = [128, :relu]
    mutation_rate = 0.0
    assert mutate_params(params, mutation_rate) == params
  end

  test "mutates params" do
    params = [:sigmoid]
    mutation_rate = 1.0
    activation_functions = activation_functions()
    [result] = mutate_params(params, mutation_rate)
    assert Enum.member?(activation_functions, result)
  end

  test "doesn't mutate layer" do
    seed_layer = {:dense, [128, :relu]}
    mutation_rate = 0.0
    assert mutate(seed_layer, mutation_rate) == seed_layer
  end

  test "mutates layer" do
    seed_layer = {:dense, [128, :relu]}
    mutation_rate = 1.0
    {new_layer_type, _params} = mutate(seed_layer, mutation_rate)
    assert Enum.member?(Map.keys(layer_types()), new_layer_type)
  end

  test "returns a layer" do
    mutation_rate = 1.0
    {layer_type, _params} = mutate_layer(mutation_rate)
    assert Enum.member?(Map.keys(layer_types()), layer_type)
  end

  test "mutates seed net" do
    seed_net = [
      {:dense, [24, :softrelu]},
      {:activation, [:tanh]},
      {:dropout, [0.25]},
      {:flatten, []}
    ]

    offspring = spawn_offspring(seed_net)
    layer_types = Map.keys(layer_types())
    assert Enum.all?(offspring, &Enum.member?(layer_types, elem(&1, 0)))
  end

  test "mutates when mutation rate is high" do
    assert should_mutate(1.0) == true
  end

  test "doesn't mutate when mutation rate is low" do
    assert should_mutate(0.0) == false
  end

  test "removes layers" do
    seed_net = [
      {:dense, [24, :softrelu]},
      {:activation, [:tanh]},
      {:dropout, [0.25]},
      {:flatten, []}
    ]

    mutation_rate = 1.0
    removed_net = remove(seed_net, mutation_rate)
    assert length(removed_net) == 0
  end
end
