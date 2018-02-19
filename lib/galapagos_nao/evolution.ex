defmodule GN.Evolution do
  import GN.Gluon

  @layer_types %{
    dense: &dense/3,
    activation: &activation/2,
    dropout: &dropout/2,
    batch_norm: &batch_norm/1,
    leaky_relu: &leaky_relu/2,
    flatten: &flatten/1
  }

  def layer_types() do
    @layer_types
  end

  @mutation_rate 0.25
  @std_dev 2

  def spawn_offspring(seed_layers, mutation_rate \\ @mutation_rate) do
    Enum.map(seed_layers, &mutate(&1, mutation_rate))
  end

  def mutate({seed_layer_type, seed_params} = _layer, mutation_rate) do
    cond do
      should_mutate(mutation_rate) -> mutate_layer(mutation_rate)
      true -> {seed_layer_type, mutate_params(seed_params, mutation_rate)}
    end
  end

  def mutate_layer(mutation_rate) do
    [new_layer_type] = Enum.take_random(Map.keys(layer_types()), 1)

    new_params =
      seed_params(new_layer_type)
      |> mutate_params(mutation_rate)

    {new_layer_type, new_params}
  end

  def mutate_params(params, mutation_rate) do
    for param <- params do
      cond do
        should_mutate(mutation_rate) ->
          cond do
            is_atom(param) ->
              Enum.take_random(activation_functions(), 1) |> hd()

            is_integer(param) ->
              Statistics.Distributions.Normal.rand(param, @std_dev)
              |> Statistics.Math.to_int()

            is_float(param) ->
              :rand.uniform()
          end

        true ->
          param
      end
    end
  end

  def seed_params(layer_type) do
    case layer_type do
      :dense -> [64, :none]
      :activation -> [:relu]
      :dropout -> [0.5]
      :leaky_relu -> [0.2]
      _ -> []
    end
  end

  def build_layer({layer_type, params}, py) do
    with_py = [py | params]
    Map.get(layer_types(), layer_type) |> apply(with_py)
  end

  def should_mutate(mutation_rate) do
    :rand.uniform() < mutation_rate
  end
end
