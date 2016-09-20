defmodule Supervisors.Brain do
  @moduledoc """
  Starts the core of the brains supervision tree
  Basic Structure:

  Brain ->
        Cerebellum
        BasalGanglia
        ThalamusMatrix
        Cortex          ->
                        ThalamusCore
                        Region        ->
                                      Layer1  ->*
                                      Layer23 ->*
                                      Layer4  ->*
                                      Layer5  ->*
                                      Layer6  ->*

  """
  use Application

  def start(_type, _args) do

    # In development, start the observer
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


    # Start the Sensory.Terminal module on application start.
    Supervisors.Cortex.start_sensory(Sensory.Terminal)
  end
end
