defmodule Supervisors.Thalamus.Core do
  use Supervisor

  @name Thalamus.Core.Supervisor

  def start_link(sense) do
    Supervisor.start_link(__MODULE__, sense, [])
  end

  def init(sense) do
    children = [
      worker(Thalamus.Core, [sense]),
      supervisor(Supervisors.Sensory, [sense])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
