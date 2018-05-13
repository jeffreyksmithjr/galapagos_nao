defmodule GN.Example do
  import GN.Orchestration, only: [evolve: 2, evolve_continual: 1]
  alias GN.Network, as: Network
  import GN.Python
  use Export.Python

  def short_example() do
    evolve(%Network{id: UUID.uuid4()}, 2)
  end

  def infinite_example() do
    evolve_continual(%Network{id: UUID.uuid4()})
  end

  def onnx_example() do
    {:ok, py} = start()
    py |> Python.call(run(), from_file: "super_resolution")
  end
end
