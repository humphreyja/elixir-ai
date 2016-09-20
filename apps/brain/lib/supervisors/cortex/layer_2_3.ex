defmodule Supervisors.Cortex.Layer23 do
  use Supervisor

  @name Layer23.Cortex.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(Cortex.Layer23, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Adds cells to layer
  """
  def build_layer(sense) do
    build_cells(sense.cell_name_prefix, sense.layer_23_count)
  end

  defp build_cells(_, 0), do: []

  defp build_cells(prefix, count) do
    name = Enum.join([prefix, "23", count], "_")
    [build_single_cell(name)] ++ build_cells(prefix, count - 1)
  end

  defp build_single_cell(name) do
    Supervisor.start_child(@name, [String.to_atom name])
  end
end
