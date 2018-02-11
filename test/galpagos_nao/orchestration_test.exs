defmodule GN.OrchestrationTest do
  use ExUnit.Case
  import GN.Orchestration

  test "parallel map is equivalent to map" do
    range = 1..10
    function = &(&1 * &1)
    expectation = Enum.map(range, function) |> Enum.into(MapSet.new())
    returned = pmap(range, function) |> Enum.into(MapSet.new())
    assert returned == expectation
  end
end
