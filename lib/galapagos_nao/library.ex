defmodule GN.Library do
  use Agent

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, opts)
  end

  def put(pid \\ __MODULE__, net) do
    Agent.update(pid, &Map.put(&1, net.id, net))
  end

  def get(pid \\ __MODULE__, net_uuid) do
    Agent.get(pid, &Map.get(&1, net_uuid, %{}))
  end

  def get_all(pid \\ __MODULE__) do
    Agent.get(pid, & &1)
  end
end
