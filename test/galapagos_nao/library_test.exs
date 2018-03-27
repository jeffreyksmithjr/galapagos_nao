defmodule GN.LibraryTest do
  use ExUnit.Case
  alias GN.Library, as: Library
  alias GN.Network, as: Network

  @test_agent_name :testable_library

  setup do
    {:ok, agent} = Library.start_link(name: @test_agent_name)
    {:ok, agent: agent}
  end

  test "adds new models to the library and returns them" do
    net = %Network{id: "a-model", layers: [:flatten, []], test_acc: 0.01}
    Library.put(@test_agent_name, net)
    assert Library.get(@test_agent_name, net.id) == net
  end

  test "gets all models from the library" do
    first_net = %Network{id: "first-model", layers: [:flatten, []], test_acc: 0.01}

    second_net = %Network{
      id: "second-model",
      layers: [{:dense, [24, :softrelu]}, {:activation, [:tanh]}, {:dropout, [0.25]}],
      test_acc: 0.01
    }

    nets = [{first_net.id, first_net}, {second_net.id, second_net}]

    for {_id, net} <- nets do
      Library.put(@test_agent_name, net)
    end

    expectation = Enum.into(nets, %{})
    assert Library.get_all(@test_agent_name) == expectation
  end
end
