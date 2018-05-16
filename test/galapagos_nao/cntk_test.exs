defmodule GN.CNTKTest do
  use ExUnit.Case
  import GN.CNTKWrapper
  import GN.Python

  test "runs CNTK example" do
    {:ok, py} = start()
    model_path = "./resources/models/MNIST/model.onnx"
    value = py |> call(evaluate(model_path))
    assert value <= 1.0
  end
end
