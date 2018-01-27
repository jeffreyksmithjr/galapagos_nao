import GN.NetBuilder

{:ok, py} = start()

l1 = py |> call(dense_relu(64))
l2 = py |> call(dense_relu(64))
l3 = py |> call(dense(64))
layers = [l1, l2, l3]

net = py |> call(build(layers))

trained_net = py |> call(run(net))

py |> call(print_net(trained_net)) |> IO.puts()