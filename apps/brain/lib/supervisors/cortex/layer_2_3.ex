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

  def start_cell(name, sense) do
     Supervisor.start_child(@name, [name, sense])
  end

  @doc """
  Adds cells to layer
  """
  def build_layer(sense) do
    inhibitory_density = sense.layer_23_inhibitory_density
    build_inhibitory_cells(sense.cell_name_prefix, sense.layer_23_count, 0, inhibitory_density)
    build_cells(sense.cell_name_prefix, sense.layer_23_count, 0, inhibitory_density, sense)
  end

  defp build_inhibitory_cells(_, 0, _, _), do: :ok
  defp build_inhibitory_cells(prefix, count, inhibitory_count, inhibitory_density) do
    if rem(count, inhibitory_density) == 0 do
      inhibitory_count = inhibitory_count + 1
      inhibitory_name = Enum.join([prefix, "23", "inhibitory", inhibitory_count], "_") |> String.to_atom
      Supervisors.Cortex.Cells.Inhibitory.start_inhibitory(inhibitory_name)
    end

    build_inhibitory_cells(prefix, count - 1, inhibitory_count, inhibitory_density)
  end

  defp build_cells(_, 0, _, _, _), do: []

  defp build_cells(prefix, count, inhibitory_count, inhibitory_density, sense) do
    name = Enum.join([prefix, "23", count], "_") |> String.to_atom
    inhibitory_name = Enum.join([prefix, "23", "inhibitory", inhibitory_count], "_") |> String.to_atom
    if rem(count, inhibitory_density) == 0 do
      inhibitory_count = inhibitory_count + 1
      inhibitory_name = Enum.join([prefix, "23", "inhibitory", inhibitory_count], "_") |> String.to_atom
    end

    Cortex.Cells.Inhibitory.add_cell(inhibitory_name, name)

    [build_single_cell(name, inhibitory_name, sense)] ++ build_cells(prefix, count - 1, inhibitory_count, inhibitory_density, sense)
  end

  defp build_single_cell(name, inhibitory_name, sense) do
    Supervisor.start_child(@name, [name, inhibitory_name, sense])
  end
end
