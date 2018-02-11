import GN.Orchestration, only: [evolve: 2]
alias GN.Network, as: Network

l1 = {:dense, [64, :relu]}
l2 = {:batch_norm, []}
l3 = {:activation, [:relu]}
l4 = {:dropout, [0.5]}
l5 = {:dense, [64, :relu]}
l6 = {:flatten, []}
l7 = {:leaky_relu, [0.2]}
l8 = {:dense, [64, :none]}
seed_layers = [l1, l2, l3, l4, l5, l6, l7, l8]

final_nets = evolve(%Network{layers: seed_layers}, 2)

IO.puts(inspect(final_nets))
