defmodule GN.SelectionTest do
  use ExUnit.Case
  import GN.Selection

  test "sets cutoffs" do
    nets = [
      %{
        layers: [
          {:dense, [24, :softrelu]},
          {:activation, [:tanh]},
          {:dropout, [0.25]},
          {:flatten, []}
        ]
      }
    ]

    expectation = [2, 4]
    assert cutoffs(nets) == expectation
  end

  test "adds new elites" do
    put(GN.Selection, 1, %{id: "old-one", layers: [:flatten, []], test_acc: 0.01})

    put(GN.Selection, 2, %{
      id: "old-two",
      layers: [{:dense, [24, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
      test_acc: 0.01
    })

    new_nets = [
      %{id: "new-one", layers: [{:dense, [12]}], test_acc: 0.50},
      %{
        id: "new-two",
        layers: [{:dense, [48, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
        test_acc: 0.60
      }
    ]

    new_elites = select(new_nets)
    new_level_1 = Map.get(new_elites, 1) |> Map.get(:id)
    new_level_2 = Map.get(new_elites, 2) |> Map.get(:id)
    assert new_level_1 == "new-one"
    assert new_level_2 == "new-two"
  end

  test "gets all elites" do
    first_net = {1, %{id: "old-one", layers: [:flatten, []], test_acc: 0.01}}

    second_net =
      {2,
       %{
         id: "old-two",
         layers: [{:dense, [24, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
         test_acc: 0.01
       }}

    elites = [first_net, second_net]

    for net <- elites do
      put(GN.Selection, elem(net, 0), elem(net, 1))
    end

    expectation = Enum.into(elites, %{})
    assert get_all(GN.Selection) == expectation
  end
end
