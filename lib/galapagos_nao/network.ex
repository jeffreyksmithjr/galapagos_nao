defmodule GN.Network do
  # FIXME: UUID is calculated at compile time, not runtime
  defstruct id: UUID.uuid4(), layers: [], test_acc: 0.0
end
