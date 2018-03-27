defmodule GN.SelectionTest do
  use ExUnit.Case
  alias GN.Selection, as: Selection
  alias GN.Network, as: Network

  @test_agent_name :testable_selection

  setup do
    {:ok, agent} = Selection.start_link(name: @test_agent_name)
    {:ok, agent: agent}
  end

  test "sets cutoffs" do
    nets = [
      %Network{
        layers: [
          {:dense, [24, :softrelu]},
          {:activation, [:tanh]},
          {:dropout, [0.25]},
          {:flatten, []}
        ]
      }
    ]

    expectation = [2, 4]
    assert Selection.cutoffs(nets) == expectation
  end

  test "adds new elites" do
    Selection.put(@test_agent_name, 1, %Network{
      id: "old-one",
      layers: [:flatten, []],
      test_acc: 0.01
    })

    Selection.put(@test_agent_name, 2, %Network{
      id: "old-two",
      layers: [{:dense, [24, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
      test_acc: 0.01
    })

    new_nets = [
      %Network{id: "new-one", layers: [{:dense, [12]}], test_acc: 0.50},
      %Network{
        id: "new-two",
        layers: [{:dense, [48, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
        test_acc: 0.60
      }
    ]

    new_elites = Selection.select(@test_agent_name, new_nets)
    new_level_1 = Map.get(new_elites, 1).id
    new_level_2 = Map.get(new_elites, 2).id
    assert new_level_1 == "new-one"
    assert new_level_2 == "new-two"
  end

  test "adds externally provided models" do
    net = %Network{id: "external-model", layers: [:flatten, []], test_acc: 0.99}
    Selection.put_unevaluated(@test_agent_name, net)

    expectation = %{-1 => net}
    assert Selection.get_all(@test_agent_name) == expectation
  end

  test "gets all elites" do
    first_net = {1, %Network{id: "old-one", layers: [:flatten, []], test_acc: 0.01}}

    second_net =
      {2,
       %Network{
         id: "old-two",
         layers: [{:dense, [24, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
         test_acc: 0.01
       }}

    elites = [first_net, second_net]

    for net <- elites do
      Selection.put(@test_agent_name, elem(net, 0), elem(net, 1))
    end

    expectation = Enum.into(elites, %{})
    assert Selection.get_all(@test_agent_name) == expectation
  end
end
