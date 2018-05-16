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

  def spawn_offspring(net, mutation_rate \\ @mutation_rate) do
    new_layers =
      duplicate(net.onnx.graph.node, mutation_rate)
      |> remove(mutation_rate)
      |> Enum.map(&mutate(&1, mutation_rate))

    update_in(net, [Access.key!(:onnx), Access.key!(:graph), Access.key!(:node)], fn n ->
      new_layers
    end)
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

  def mutate(
        %Onnx.NodeProto{
          attribute: [%Onnx.AttributeProto{t: %Onnx.TensorProto{float_data: float_data}}]
        } = layer,
        mutation_rate
      ) do
    mutated_data = mutate_params(float_data, mutation_rate)

    update_in(
      layer,
      [Access.key!(:attribute), Access.all(), Access.key!(:t), Access.key!(:float_data)],
      fn d -> mutated_data end
    )
  end

  def mutate(layer, _mutation_rate) do
    layer
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
              Statistics.Distributions.Normal.rand(param, @std_dev)
          end

        true ->
          param
      end
    end
  end

  def seed_params(layer_type) do
    GN.Parameters.get(__MODULE__, :layer_types)
    |> Map.get(layer_type, [])
  end

  def build_layer({layer_type, params}, py) do
    with_py = [py | params]
    Map.get(layer_types(), layer_type) |> apply(with_py)
  end

  def should_mutate(mutation_rate) do
    :rand.uniform() < mutation_rate
  end
end
