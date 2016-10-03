defmodule Sensory.Terminal do
  @moduledoc """
  Takes in any amount of terminal input and breaks it into strings of
  @max_characters (10) length and creates an SDR of each string
  """

  use GenServer

  @character_max_attr 50
  @max_characters 10
  @name Terminal.Sensory

  """
  Constant attributes that declare naming conventions and describe the cortex sizes
  """
  def cortex_name, do: Terminal.Sensory.Cortex
  def thalamus_name, do: Terminal.Sensory.Thalamus.Core
  def cell_name_prefix, do: "sensory_terminal"
  def layer_1_count, do: 50
  def layer_23_count, do: round (Sensory.Terminal.layer_4_count / 2)
  def layer_4_count, do: @character_max_attr * @max_characters
  def layer_5_count, do: 50
  def layer_6_count, do: 50
  def layer_23_inhibitory_density, do: 10
  def cortex_column_count, do: 50

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Initializes the sense.  Constructs each cortex layer based on the modules
  specification declared in the functions above.
  """
  def init(:ok) do
    Supervisors.Cortex.Layer1.build_layer(__MODULE__)
    Supervisors.Cortex.Layer23.build_layer(__MODULE__)
    #Supervisors.Cortex.Layer23Inhibitory.add_to_layer_2_3(__MODULE__)
    Supervisors.Cortex.Layer4.build_layer(__MODULE__)
    Supervisors.Cortex.Layer5.build_layer(__MODULE__)
    Supervisors.Cortex.Layer6.build_layer(__MODULE__)
    {:ok, %{}}
  end

  def read(_server, ""), do: :ok

  @doc """
  Reads in a string of characters and breaks them into strings @max_characters
  long.  Then recursively does that again until there are no more characters left.
  It will take each character, find its visual representation, and construct a list
  that can be @max_characters * @character_max_attr long.  Then it sends that list
  to the Thalamus Core associated with the sense (provided in the function above).

  ## Examples

      iex> Brain.Sensory.Terminal.read(Sensory.Terminal, "abds")
      :ok

  """
  def read(server, text) do
    {current_read, rest} = String.split_at(text, @max_characters)
    GenServer.cast(server, {:read, current_read})
    :timer.sleep(40)
    read(server, rest)
  end

  @doc """
  Tests the module to determine if the correct sdr is formed for the inputed
  characters
  """
  def input_first(server, text) do
    {current_read, _rest} = String.split_at(text, @max_characters)
    GenServer.call(server, {:test_read, current_read})
  end

  @doc """
  Gets the visual representation of a single character.  Used in testing.
  """
  def get_sdr(server, char) do
    GenServer.call(server, {:get_char, char})
  end

  @doc """
  Handles casts from the read function.  It will get the full character
  attribute list and use that as input to the senses thalamus core.
  """
  def handle_cast({:read, text}, state) do
    # TODO: (Sensory): On each message, send sdr to Thalamus core.
    characters = String.codepoints(text)
    full_sdr = find_char_and_adjust_sdr(characters, 0)
    Thalamus.Core.sensory_input(thalamus_name, full_sdr)

    {:noreply, state}
  end

  def handle_call({:test_read, text}, _from, state) do
    characters = String.codepoints(text)
    full_sdr = find_char_and_adjust_sdr(characters, 0)
    {:reply, full_sdr, state}
  end

  def handle_call({:get_char, char}, _from, state) do
    {:reply, char_to_sdr(char), state}
  end

  """
  Used to create a list of character attributes by increasing the next characters
  attribute list by @character_max_attr.  So for a list of 10 characters with 50 attributes
  total, there would be a list that can be max 500 elements long.
  """
  defp find_char_and_adjust_sdr([], _incr), do: []
  defp find_char_and_adjust_sdr([char|rest], incr) do
    Enum.map(char_to_sdr(char), &(&1 + incr)) ++ find_char_and_adjust_sdr(rest, incr + @character_max_attr)
  end

  """
  Contains a map of every character on a US Mac keyboard, with a list of attributes
  that visually describe the character.  This makes characters like 1 and l visualy
  similar.
  """
  defp char_to_sdr(char) do
    character_map = %{
      "1" => [11, 12, 16, 30, 39, 41],
      "2" => [5, 7, 9, 11, 12, 15, 21, 29, 32, 41],
      "3" => [4, 5, 6, 8, 9, 10, 12, 15, 21, 29, 33, 41, 43],
      "4" => [1, 5, 9, 11, 12, 16, 18, 30, 38, 39, 41],
      "5" => [6, 7, 10, 11, 12, 16, 21, 30, 32, 41],
      "6" => [1, 2, 6, 7, 10, 13, 21, 32, 40],
      "7" => [5, 8, 10, 11, 12, 15, 29, 37, 38, 41],
      "8" => [1, 2, 4, 5, 6, 21, 28, 33],
      "9" => [1, 2, 5, 8, 9, 13, 21, 28, 32, 41],
      "0" => [1, 2, 4, 21, 24, 29, 32, 44],
      "!" => [11, 14, 27, 28, 36, 39],
      "@" => [1, 2, 4, 7, 8, 9, 10, 13, 21, 24, 28, 33, 41],
      "#" => [1, 3, 4, 11, 12, 18, 19, 22, 23, 24, 31, 34, 37, 38, 42, 43],
      "$" => [4, 7, 8, 9, 10, 11, 16, 18, 21, 24, 29, 33, 39],
      "%" => [1, 2, 4, 11, 14, 19, 21, 24, 30, 33, 36, 37],
      "^" => [0, 5, 11, 12, 15, 23, 25, 29, 37],
      "*" => [0, 2, 4, 11, 12, 19, 25, 30, 35, 37],
      "(" => [14, 21, 28, 32, 40, 42],
      ")" => [14, 21, 28, 32, 41, 43],
      "-" => [0, 11, 14, 25, 28, 38],
      "=" => [0, 11, 16, 29, 36, 38],
      "_" => [11, 14, 24, 28, 38],
      "+" => [0, 4, 11, 12, 16, 18, 25, 29, 38, 39],
      "[" => [3, 11, 12, 16, 30, 38, 39, 40, 42],
      "]" => [3, 11, 12, 16, 30, 38, 39, 41, 43],
      "{" => [8, 12, 15, 21, 29, 33, 40, 42],
      "}" => [7, 12, 15, 21, 29, 33, 41, 43],
      "\\" => [11, 14, 28, 37, 41],
      "|" => [11, 14, 28, 39],
      "," => [6, 11, 14, 25, 28, 37, 41],
      "." => [2, 6, 11, 25, 27],
      "/" => [11, 14, 28, 37, 40],
      "<" => [0, 4, 11, 12, 15, 25, 29, 37, 40, 42],
      ">" => [0, 4, 11, 12, 15, 25, 29, 37, 41, 43],
      "?" => [5, 8, 10, 14, 21, 27, 28, 32, 41, 43],
      ";" => [6, 11, 14, 25, 26, 28, 36, 37, 41],
      ":" => [14, 25, 26, 27, 36],
      "'" => [0, 5, 11, 14, 25, 28, 39],
      "\"" => [0, 11, 16, 25, 29, 36, 39],
      "`" => [0, 5, 11, 14, 25, 28, 37, 40],
      "~" => [0, 14, 21, 25, 28, 33, 38],
      "a" => [1, 6, 8, 10, 14, 21, 25, 29, 33, 41],
      "b" => [1, 2, 6, 10, 11, 14, 21, 25, 29, 32, 39, 40],
      "c" => [2, 4, 7, 9, 10, 14, 21, 25, 28, 32, 40, 42, 44],
      "d" => [1, 2, 6, 10, 11, 14, 21, 25, 29, 32, 39, 41],
      "e" => [1, 2, 4, 7, 9, 11, 12, 13, 18, 20, 21, 25, 29, 32, 40, 44],
      "f" => [5, 7, 10, 11, 12, 16, 18, 21, 25, 29, 32, 38, 39, 40, 42],
      "g" => [1, 2, 5, 8, 9, 11, 14, 21, 25, 29, 32, 41],
      "h" => [6, 10, 11, 15, 21, 23, 25, 29, 32, 39, 40],
      "i" => [11, 14, 25, 26, 28, 36, 39],
      "j" => [6, 8, 9, 11, 14, 21, 25, 26, 28, 32, 36, 39, 41],
      "k" => [6, 10, 11, 12, 16, 19, 20, 25, 30, 37, 40, 42],
      "l" => [4, 11, 14, 25, 28, 39],
      "m" => [4, 10, 11, 16, 21, 23, 25, 30, 33, 40],
      "n" => [4, 10, 11, 15, 21, 23, 25, 29, 32, 40],
      "o" => [1, 2, 4, 21, 25, 28, 32, 44],
      "p" => [1, 2, 5, 9, 11, 14, 21, 25, 29, 32, 39, 40],
      "q" => [1, 2, 5, 9, 11, 14, 21, 25, 29, 32, 39, 41],
      "r" => [7, 10, 11, 15, 21, 25, 29, 32, 40],
      "s" => [7, 8, 9, 10, 14, 21, 25, 28, 33],
      "t" => [5, 9, 11, 12, 16, 18, 25, 29, 38, 39],
      "u" => [4, 9, 11, 15, 21, 22, 25, 29, 32, 41],
      "v" => [4, 11, 12, 15, 22, 25, 29, 37],
      "w" => [4, 11, 12, 17, 22, 25, 31, 37],
      "x" => [4, 11, 12, 16, 19, 25, 29, 37],
      "y" => [5, 8, 9, 11, 12, 15, 19, 20, 22, 25, 29, 37, 41],
      "z" => [4, 7, 8, 9, 10, 11, 12, 16, 19, 20, 25, 30, 38, 41],
      "A" => [1, 4, 9, 11, 12, 15, 18, 20, 23, 24, 30, 37],
      "B" => [1, 4, 11, 14, 21, 24, 30, 33, 39, 40],
      "C" => [2, 4, 7, 9, 10, 21, 24, 28, 32, 40, 42, 44],
      "D" => [1, 4, 11, 14, 21, 24, 29, 32, 39, 40],
      "E" => [3, 4, 7, 11, 12, 17, 24, 31, 38, 39, 40, 42],
      "F" => [3, 5, 7, 11, 12, 16, 24, 30, 38, 39, 40, 42],
      "G" => [2, 6, 7, 10, 11, 16, 21, 24, 30, 32, 40, 44],
      "H" => [3, 4, 11, 12, 16, 18, 20, 22, 23, 24, 30, 39],
      "I" => [4, 11, 12, 16, 18, 20, 24, 30, 38],
      "J" => [6, 8, 9, 11, 12, 15, 18, 20, 21, 24, 29, 32, 39, 41],
      "K" => [4, 11, 12, 16, 19, 20, 24, 30, 37, 40, 42],
      "L" => [6, 7, 9, 11, 12, 15, 18, 20, 24, 29, 38, 39, 40],
      "M" => [4, 11, 12, 17, 23, 24, 31, 37, 39],
      "N" => [4, 11, 12, 16, 19, 20, 24, 30, 39, 40],
      "O" => [1, 2, 4, 21, 24, 28, 32, 44],
      "P" => [1, 5, 9, 11, 14, 21, 24, 29, 32, 39, 40],
      "Q" => [1, 2, 4, 7, 9, 13, 21, 24, 29, 32, 40, 44],
      "R" => [1, 5, 7, 9, 11, 12, 15, 21, 23, 24, 30, 32, 39, 40],
      "S" => [4, 7, 8, 9, 10, 14, 21, 24, 28, 33],
      "T" => [5, 9, 11, 12, 15, 18, 20, 24, 29, 38, 39],
      "U" => [4, 11, 14, 21, 22, 24, 28, 32, 39],
      "V" => [4, 11, 12, 15, 22, 24, 29, 37],
      "W" => [4, 11, 12, 17, 22, 24, 31, 37],
      "X" => [4, 11, 12, 16, 19, 24, 29, 37],
      "Y" => [5, 9, 11, 12, 15, 19, 20, 22, 24, 30, 37],
      "Z" => [4, 7, 8, 9, 10, 11, 12, 16, 19, 20, 24, 30, 38, 41]
    }

    case Map.fetch(character_map, char) do
      {:ok, sdr} ->
        sdr
      :error ->
        []
    end
  end
end
