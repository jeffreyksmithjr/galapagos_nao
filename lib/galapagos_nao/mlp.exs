import GN.NetBuilder

{:ok, py} = start()

l1 = py |> dense(64, :relu)
l2 = py |> batch_norm()
l3 = py |> activation(:relu)
l4 = py |> dropout(0.5)
l5 = py |> dense(64, :relu)
l6 = py |> flatten()
l7 = py |> leaky_relu(0.2)
l8 = py |> dense(64)
layers = [l1, l2, l3, l4, l5, l6, l7, l8]

net = py |> call(build(layers))

trained_net = py |> call(run(net))

py |> call(print_net(trained_net)) |> IO.puts()
