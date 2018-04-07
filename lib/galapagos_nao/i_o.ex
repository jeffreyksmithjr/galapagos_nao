defmodule GN.IO do
  def write_net(net) do
    write(Poison.encode!(net.json), net.id, "json")
    write(net.params, net.id, "params")
    :ok
  end

  def write(data, net_id, extension) do
    {:ok, file} = File.open("/tmp/#{net_id}.#{extension}", [:write])
    IO.binwrite(file, data)
    File.close(file)
  end
end
