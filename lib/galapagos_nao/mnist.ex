defmodule GN.MNIST do
  defmacro call(instance, expression) do
    {function, _meta, arguments} = expression
    arguments = arguments || []

    quote do
      :python.call(unquote(instance), :mnist, unquote(function), unquote(arguments))
    end
  end
end
