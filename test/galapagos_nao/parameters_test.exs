defmodule GN.ParametersTest do
  use ExUnit.Case
  import GN.Parameters

  @test_agent_name :testable_parameters

  setup do
    {:ok, agent} = GN.Parameters.start_link(name: @test_agent_name)
    {:ok, agent: agent}
  end

  test "matches initial parameters" do
    complexity_levels = get(@test_agent_name, GN.Selection, :complexity_levels)
    default = 2
    assert complexity_levels == default
  end

  test "changes parameters" do
    new_complexity = 4
    put(@test_agent_name, GN.Selection, %{complexity_levels: 4})
    complexity_levels = get(@test_agent_name, GN.Selection, :complexity_levels)
    assert complexity_levels == new_complexity
  end

  test "changes nested parameters" do
    new_generation_size = 8
    put(@test_agent_name, GN.Orchestration, %{generation_size: new_generation_size})
    generation_size = get(@test_agent_name, GN.Orchestration, :generation_size)
    assert generation_size == new_generation_size
  end

  test "leaves existing parameters unchanged" do
    initial_timeout = get(@test_agent_name, GN.Orchestration, :timeout)
    new_generation_size = 8
    put(@test_agent_name, GN.Orchestration, %{generation_size: new_generation_size})
    timeout = get(@test_agent_name, GN.Orchestration, :timeout)
    assert initial_timeout == timeout
  end
end
