defmodule GN.CNTKTest do
  use ExUnit.Case
  import GN.Gluon

  test "runs CNTK example" do
    {:ok, py} = start()
    [last, avg] = py |> call(ffnet())
    assert last < 1.0
    assert avg < 1.0
  end
end
