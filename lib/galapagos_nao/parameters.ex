defmodule GN.Parameters do
  use Agent

  def start_link(_) do
    evolution = Confex.fetch_env!(:galapagos_nao, GN.Evolution)
    orchestration = Confex.fetch_env!(:galapagos_nao, GN.Orchestration)
    selection = Confex.fetch_env!(:galapagos_nao, GN.Selection)

    initial = %{
      GN.Evolution => evolution,
      GN.Orchestration => orchestration,
      GN.Selection => selection
    }

    Agent.start_link(fn -> initial end, name: __MODULE__)
  end

  def put(module, parameters) do
    Agent.update(__MODULE__, &Map.put(&1, module, parameters))
  end

  def get(module, parameter) do
    Agent.get(__MODULE__, &Map.get(&1, module, %{}))[parameter]
  end
end
