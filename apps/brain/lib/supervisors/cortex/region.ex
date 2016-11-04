defmodule Supervisors.Cortex.Region do
  use Supervisor

  def start_link(sense) do
    Supervisor.start_link(__MODULE__, :ok, name: sense.cortex_name)
  end

  def init(:ok) do
    children = [
      supervisor(Supervisors.Cortex.Layer1 , []),
      supervisor(Supervisors.Cortex.Cells.Inhibitory , []),
      supervisor(Supervisors.Cortex.Layer23 , []),
      supervisor(Supervisors.Cortex.Layer4 , []),
      supervisor(Supervisors.Cortex.Layer5 , []),
      supervisor(Supervisors.Cortex.Layer6 , [])
    ]

    supervise(children, strategy: :one_for_one)
  end


  def construct_columns(sense) do
    layer1_per_column = round sense.layer_1_count / sense.cortex_column_count
    layer23_per_column = round sense.layer_23_count / sense.cortex_column_count
    layer4_per_column = round sense.layer_4_count / sense.cortex_column_count
    layer5_per_column = round sense.layer_5_count / sense.cortex_column_count
    layer6_per_column = round sense.layer_6_count / sense.cortex_column_count

    build_inhibitory_cells(sense.layer_23_inhibitory_density, sense)
    inhibit_coef = round(sense.cortex_column_count / sense.layer_23_inhibitory_density)
    build_columns(sense.cortex_column_count, inhibit_coef, 0, layer1_per_column, layer23_per_column, layer4_per_column, layer5_per_column, layer6_per_column, sense)
  end

  defp build_inhibitory_cells(0, _), do: :ok
  defp build_inhibitory_cells(count, sense) do
    name = cell_name(sense.cell_name_prefix, "23_inhibitory", count)
    Supervisors.Cortex.Cells.Inhibitory.start_inhibitory(name)
    build_inhibitory_cells(count - 1, sense)
  end

  defp build_columns(0, _, _, _, _, _, _, _, _), do: :ok
  defp build_columns(count, inhibitory_coef, inhibitory_count, layer1_per_column, layer23_per_column, layer4_per_column, layer5_per_column, layer6_per_column, sense) do
    inhibitory_name = cell_name(sense.cell_name_prefix, "23_inhibitory", inhibitory_count)

    if rem(count, inhibitory_coef) == 0 do
      inhibitory_count = inhibitory_count + 1
      inhibitory_name = cell_name(sense.cell_name_prefix, "23_inhibitory", inhibitory_count)
    end

    l1_cells = build_layer_1_cells(layer1_per_column, layer1_per_column * count, sense)
    l23_cells = build_layer_23_cells(layer23_per_column, layer23_per_column * count, inhibitory_name, sense)
    l4_cells = build_layer_4_cells(layer4_per_column, layer4_per_column * count, sense)
    l5_cells = build_layer_5_cells(layer5_per_column, layer5_per_column * count, sense)
    l6_cells = build_layer_6_cells(layer6_per_column, layer6_per_column * count, sense)

    Cortex.Cells.Inhibitory.associate_cells(inhibitory_name, l23_cells)

    column_cells = %{l1: l1_cells, l23: l23_cells, l4: l4_cells, l5: l5_cells, l6: l6_cells}

    layer_1_associate_cells(Map.to_list(l1_cells), column_cells)
    layer_23_associate_cells(Map.to_list(l23_cells), column_cells)
    layer_4_associate_cells(Map.to_list(l4_cells), column_cells)
    layer_5_associate_cells(Map.to_list(l5_cells), column_cells)
    layer_6_associate_cells(Map.to_list(l6_cells), column_cells)

    build_columns(count - 1, inhibitory_coef, inhibitory_count, layer1_per_column, layer23_per_column, layer4_per_column, layer5_per_column, layer6_per_column, sense)
  end

  defp layer_1_associate_cells([], _), do: :ok
  defp layer_1_associate_cells([{cell, _weight}|cells], column_cells) do
     Cortex.Layer1.associate(cell, column_cells)
     layer_1_associate_cells(cells, column_cells)
  end

  defp layer_23_associate_cells([], _), do: :ok
  defp layer_23_associate_cells([{cell, _weight}|cells], column_cells) do
     Cortex.Layer23.associate(cell, column_cells)
     layer_23_associate_cells(cells, column_cells)
  end

  defp layer_4_associate_cells([], _), do: :ok
  defp layer_4_associate_cells([{cell, _weight}|cells], column_cells) do
     Cortex.Layer4.associate(cell, column_cells)
     layer_4_associate_cells(cells, column_cells)
  end

  defp layer_5_associate_cells([], _), do: :ok
  defp layer_5_associate_cells([{cell, _weight}|cells], column_cells) do
     Cortex.Layer5.associate(cell, column_cells)
     layer_5_associate_cells(cells, column_cells)
  end

  defp layer_6_associate_cells([], _), do: :ok
  defp layer_6_associate_cells([{cell, _weight}|cells], column_cells) do
     Cortex.Layer6.associate(cell, column_cells)
     layer_6_associate_cells(cells, column_cells)
  end

  defp build_layer_1_cells(0, _, _), do: %{}
  defp build_layer_1_cells(count, column, sense) do
    #c_id = count + column
    #name = cell_name(sense.cell_name_prefix, "1", c_id)
    #Supervisors.Cortex.Layer1.start_cell(name, sense)
    name = Cortex.Layer1.prefix_to_name(sense.cell_name_prefix)
    Supervisors.Cortex.Layer1.start_cell(name, sense)
    Map.put(build_layer_1_cells(count - 1, column, sense), name, 1)
  end

  defp build_layer_23_cells(0, _, _, _), do: %{}
  defp build_layer_23_cells(count, column, inhibitory_name, sense) do
    c_id = count + column
    name = cell_name(sense.cell_name_prefix, "23", c_id)
    Supervisors.Cortex.Layer23.start_cell(name, inhibitory_name, sense)
    Map.put(build_layer_23_cells(count - 1, column, inhibitory_name, sense), name, 1)
  end

  defp build_layer_4_cells(0, _, _), do: %{}
  defp build_layer_4_cells(count, column, sense) do
    c_id = count + column
    name = cell_name(sense.cell_name_prefix, "4", c_id)
    Supervisors.Cortex.Layer4.start_cell(name, sense)
    Map.put(build_layer_4_cells(count - 1, column, sense), name, 1)
  end

  defp build_layer_5_cells(0, _, _), do: %{}
  defp build_layer_5_cells(count, column, sense) do
    c_id = count + column
    name = cell_name(sense.cell_name_prefix, "5", c_id)
    Supervisors.Cortex.Layer5.start_cell(name, sense)
    Map.put(build_layer_5_cells(count - 1, column, sense), name, 1)
  end

  defp build_layer_6_cells(0, _, _), do: %{}
  defp build_layer_6_cells(count, column, sense) do
    c_id = count + column
    name = cell_name(sense.cell_name_prefix, "6", c_id)
    Supervisors.Cortex.Layer6.start_cell(name, sense)
    Map.put(build_layer_6_cells(count - 1, column, sense), name, 1)
  end

  """
  Build cell name from sense prefix, layer, and cell number
  """
  defp cell_name(prefix, layer, number) do
    String.to_atom Enum.join([prefix, layer, number], "_")
  end
end
