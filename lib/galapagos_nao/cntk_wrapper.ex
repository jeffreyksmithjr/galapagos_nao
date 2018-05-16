defmodule GN.CNTKWrapper do
  defmacro call(instance, expression) do
    {function, _meta, arguments} = expression
    arguments = arguments || []

    quote do
      :python.call(unquote(instance), :cntk_wrapper, unquote(function), unquote(arguments))
    end
  end
end
