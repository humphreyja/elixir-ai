defmodule Sensory.Muscle do
  use GenServer

  @name Muscle.Sensory

  def cortex_name, do: Muscle.Sensory.Cortex
  def thalamus_name, do: Muscle.Sensory.Thalamus.Core

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    # TODO (Sensory): Spawn executable for motor.  Store process in state.
    {:ok, %{}}
  end
end
