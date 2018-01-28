import GN.NetBuilder

{:ok, py} = start()

l1 = py |> dense(64, :relu)
l2 = py |> dense(64, :relu)
l3 = py |> activation(:relu)
l4 = py |> dense(64)
layers = [l1, l2, l3, l4]

net = py |> call(build(layers))

trained_net = py |> call(run(net))

py |> call(print_net(trained_net)) |> IO.puts()
