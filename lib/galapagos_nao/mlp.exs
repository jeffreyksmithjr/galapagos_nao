import GN.Orchestration
import GN.Selection, only: [select: 1]
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

nets = learn_generation(%{-1 => %Network{layers: seed_layers}})

IO.puts("First generation")
inspect_generation(nets)

new_nets = select(nets)

IO.puts("Selected winners")
inspect_generation(new_nets)

next_nets = learn_generation(new_nets)

final_nets = select(next_nets)

IO.puts("Final winners")
inspect_generation(final_nets)
