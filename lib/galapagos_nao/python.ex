defmodule GN.Python do
  def start() do
    Export.Python.start(python: "python", python_path: Path.expand("lib/python"))
  end
end
