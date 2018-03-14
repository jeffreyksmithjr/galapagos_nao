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
    duplicate(seed_layers, mutation_rate)
    |> remove(mutation_rate)
    |> Enum.map(&mutate(&1, mutation_rate))
  end

  def duplicate(seed_layers, mutation_rate, all \\ false) do
    cond do
      should_mutate(mutation_rate) ->
        end_index = length(seed_layers) - 1
        duplicate_segment = random_slice(seed_layers, all)
        insertion_point = find_insertion_point(end_index)

        Enum.concat([
          Enum.slice(seed_layers, 0..insertion_point),
          duplicate_segment,
          Enum.slice(seed_layers, (insertion_point + 1)..end_index)
        ])

      true ->
        seed_layers
    end
  end

  def random_slice(seed_layers, true) do
    seed_layers
  end

  def random_slice(seed_layers, _false) do
    end_index = length(seed_layers) - 1
    [slice_start, slice_finish] = find_slice(end_index)
    Enum.slice(seed_layers, slice_start..slice_finish)
  end

  def find_slice(end_index) do
    Enum.take_random(0..end_index, 2) |> Enum.sort()
  end

  def find_insertion_point(end_index) do
    Enum.take_random(0..end_index, 1) |> hd()
  end

  def remove(seed_layers, mutation_rate) do
    Enum.filter(seed_layers, fn _ -> !should_mutate(mutation_rate) end)
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
    {:ok, [layer_types: types]} = Confex.fetch_env(:galapagos_nao, GN.Evolution)
    Map.get(types, layer_type, [])
  end

  def build_layer({layer_type, params}, py) do
    with_py = [py | params]
    Map.get(layer_types(), layer_type) |> apply(with_py)
  end

  def should_mutate(mutation_rate) do
    :rand.uniform() < mutation_rate
  end
end
