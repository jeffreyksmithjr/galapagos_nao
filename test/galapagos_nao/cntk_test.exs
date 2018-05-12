defmodule GN.CNTKTest do
  use ExUnit.Case
  import GN.CNTKWrapper
  import GN.Python

  test "runs CNTK example" do
    {:ok, py} = start()
    model_path = "./resources/models/mnist/model.onnx"
    [last, _data] = py |> call(ffnet(model_path))
    assert last <= 1.0
  end
end
