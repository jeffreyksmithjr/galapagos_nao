defmodule GN.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Task.Supervisor, [[name: GN.TaskSupervisor]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
