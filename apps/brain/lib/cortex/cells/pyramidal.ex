defmodule Cortex.Cells.Pyramidal do

  def start do
    spawn(fn ->
      listening_cycle
    end)
  end

  """
  The Cycle for a cell is on first input, listen for the next 40 mil seconds
  before cutting off any more input.
  """
  defp listening_cycle do
     :timer.sleep(40)
  end
end
