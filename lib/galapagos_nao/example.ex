defmodule GN.Example do
  import GN.Orchestration, only: [evolve: 2, evolve_continual: 1]
  alias GN.Network, as: Network

  def seed_layers() do
    l1 = {:dense, [64, :relu]}
    l2 = {:batch_norm, []}
    l3 = {:activation, [:relu]}
    l4 = {:dropout, [0.5]}
    l5 = {:dense, [64, :relu]}
    l6 = {:flatten, []}
    l7 = {:leaky_relu, [0.2]}
    l8 = {:dense, [64, :none]}
    [l1, l2, l3, l4, l5, l6, l7, l8]
  end

  def short_example() do
    evolve(%Network{id: UUID.uuid4(), layers: seed_layers()}, 2)
  end

  def infinite_example() do
    evolve_continual(%Network{id: UUID.uuid4(), layers: seed_layers()})
  end
end
