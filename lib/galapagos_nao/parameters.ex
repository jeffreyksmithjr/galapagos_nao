defmodule GN.Parameters do
  use Agent

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    evolution = Confex.fetch_env!(:galapagos_nao, GN.Evolution)
    orchestration = Confex.fetch_env!(:galapagos_nao, GN.Orchestration)
    selection = Confex.fetch_env!(:galapagos_nao, GN.Selection)

    initial = %{
      GN.Evolution => evolution,
      GN.Orchestration => orchestration,
      GN.Selection => selection
    }

    Agent.start_link(fn -> initial end, opts)
  end

  def put(pid \\ __MODULE__, module, parameters) do
    Agent.update(pid, &Map.put(&1, module, parameters))
  end

  def get(pid \\ __MODULE__, module, parameter) do
    Agent.get(pid, &Map.get(&1, module, %{}))[parameter]
  end
end
