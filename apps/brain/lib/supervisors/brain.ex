defmodule Supervisors.Brain do
  use Application

  def start(_type, _args) do

    if Mix.env == :dev do
      :observer.start
    end


    import Supervisor.Spec, warn: false
    children = [
      worker(Thalamus.Matrix, []),
      worker(Cerebellum.Cerebellum, []),
      worker(BasalGanglia.BasalGanglia, []),
      supervisor(Supervisors.Cortex, [])
    ]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)



    Supervisors.Cortex.start_sensory(Sensory.Terminal)
  end
end
