defmodule GN.EvolutionTest do
  use ExUnit.Case
  import GN.Evolution
  import GN.Gluon, only: [start: 0]

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
end
