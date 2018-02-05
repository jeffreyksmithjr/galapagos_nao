defmodule GN.Gluon do
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

  # Basic layers
  @activation_functions [:relu, :sigmoid, :tanh, :softrelu, :none]
  @type activation_functions :: :relu | :sigmoid | :tanh | :softrelu | :none

  def activation_functions() do
    @activation_functions
  end

  @spec dense(any(), integer, activation_functions) :: any()
  def dense(py, n, activation) do
    act_type = Atom.to_string(activation)
    py |> call(dense(n, act_type))
  end

  @spec activation(any(), activation_functions) :: any()
  def activation(py, activation) do
    act_type = Atom.to_string(activation)
    py |> call(activation(act_type))
  end

  def dropout(py, rate) do
    py |> call(dropout(rate))
  end

  def batch_norm(py) do
    py |> call(batch_norm())
  end

  def leaky_relu(py, alpha) do
    py |> call(leaky_relu(alpha))
  end

  def flatten(py) do
    py |> call(flatten())
  end
end
