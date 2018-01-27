defmodule GNTest do
  use ExUnit.Case
  doctest GN

  test "greets the world" do
    assert GN.hello() == :world
  end
end
