defmodule Supervisors.Cortex.Layer5 do
  use Supervisor

  @name Layer5.Cortex.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(Cortex.Layer5, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Adds cells to layer
  """
  def build_layer(sense) do
    build_cells(sense.cell_name_prefix, sense.layer_5_count, sense)
  end

  defp build_cells(_, 0, _), do: []

  defp build_cells(prefix, count, sense) do
    name = Enum.join([prefix, "5", count], "_")
    [build_single_cell(name, sense)] ++ build_cells(prefix, count - 1, sense)
  end

  defp build_single_cell(name, sense) do
    Supervisor.start_child(@name, [String.to_atom(name), sense])
  end
end
