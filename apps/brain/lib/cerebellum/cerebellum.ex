defmodule Cerebellum.Cerebellum do
  use GenServer

  @name Cerebellum

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    {:ok, %{}}
  end
end
