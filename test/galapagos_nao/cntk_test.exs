defmodule GN.CNTKTest do
  use ExUnit.Case
  import GN.Gluon

  @tag :skip
  test "runs CNTK example" do
    {:ok, py} = start()
    [last, avg] = py |> call(ffnet(:nothing))
    assert last < 1.0
    assert avg < 1.0
  end
end
