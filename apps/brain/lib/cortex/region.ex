defmodule Cortex.Region do
  @moduledoc """
  Manages the cortex region.  TODO: Everything for cortex region
  """

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, %{}}
  end
end
