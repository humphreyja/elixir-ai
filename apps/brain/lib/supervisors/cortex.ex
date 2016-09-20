defmodule Supervisors.Cortex do
  use Supervisor

  @name Cortex.Supervisor

  @doc """
  Starts a new sensory region
  """
  def start_sensory(sense) do
    Supervisor.start_child(@name, [sense])
  end

  @doc """
  Starts a new region process
  """
  def start_region do
    Supervisor.start_child(@name, [:root])
  end


  @doc """
  Starts the root of all cortex processes
  """
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  @doc """
  Starts a new region of cortex
  """
  def start_link(:root) do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Starts a sensory region with a new sense
  """
  def start_link(sense) do
    Supervisor.start_link(__MODULE__, sense, [])
  end

  @doc """
  Generic region
  """
  def init(:ok) do
    children = [
      supervisor(Supervisors.Cortex, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Sensory region with Thalamus attached
  """
  def init(sense) do
    children = [
      supervisor(Supervisors.Cortex.Region, [sense]),
      supervisor(Supervisors.Thalamus.Core, [sense])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
