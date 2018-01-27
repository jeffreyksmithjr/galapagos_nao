defmodule GN.NetBuilder do

  def start() do
    Export.Python.start(python: "python3", python_path: Path.expand("lib/python"))
  end

  defmacro call(instance, expression) do
    {function, _meta, arguments} = expression
    arguments = arguments || []
    quote do
      :python.call(unquote(instance), :gluon, unquote(function), unquote(arguments))
    end
  end

end