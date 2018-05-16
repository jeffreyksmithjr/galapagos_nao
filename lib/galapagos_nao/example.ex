defmodule GN.Example do
  import GN.Orchestration, only: [evolve: 2, evolve_continual: 1]
  alias GN.Network, as: Network
  import GN.Python
  use Export.Python

  def example_net() do
    {:ok, net_data} = File.read("./resources/models/MNIST/model.onnx")
    model_struct = Onnx.ModelProto.decode(net_data)
    %Network{onnx: model_struct}
  end

  def short_example() do
    evolve(example_net(), 2)
  end

  def infinite_example() do
    evolve_continual(example_net())
  end

  def onnx_example() do
    {:ok, py} = start()
    py |> Python.call(run(), from_file: "super_resolution")
  end
end
