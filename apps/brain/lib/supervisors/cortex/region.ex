defmodule Supervisors.Cortex.Region do
  use Supervisor

  def start_link(sense) do
    Supervisor.start_link(__MODULE__, :ok, name: sense.cortex_name)
  end

  def init(:ok) do
    children = [
      supervisor(Supervisors.Cortex.Layer1 , []),
      supervisor(Supervisors.Cortex.Layer23 , []),
      supervisor(Supervisors.Cortex.Layer4 , []),
      supervisor(Supervisors.Cortex.Layer5 , []),
      supervisor(Supervisors.Cortex.Layer6 , [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
