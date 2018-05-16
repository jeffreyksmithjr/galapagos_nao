defmodule GN.Network do
  # FIXME: UUID is calculated at compile time, not runtime
  defstruct id: UUID.uuid4(),
            test_acc: 0.0,
            onnx: %Onnx.ModelProto{graph: %Onnx.GraphProto{node: []}}
end
