defmodule Sensory.TerminalTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, term} = Sensory.Terminal.start_link(:default)
    {:ok, term: term}
  end

  test "gets SDR based on character", %{term: term} do
    assert Sensory.Terminal.get_sdr(term, "a") == [1, 6, 8, 10, 14, 21, 25, 29, 33, 41]
    assert Sensory.Terminal.get_sdr(term, "\\") == [11, 14, 28, 37, 41]
  end

  test "gets SDR for special characters", %{term: term} do
    assert Sensory.Terminal.get_sdr(term, "\\") == [11, 14, 28, 37, 41]
  end

  test "returns empty list for unmapped characters", %{term: term} do
    assert Sensory.Terminal.get_sdr(term, "\n") == []
  end

  test "inputting empty string to block input returns empty SDR", %{term: term} do
    assert Sensory.Terminal.input_first(term, "") == []
  end

  test "inputting string to block input returns full SDR", %{term: term} do
    assert Sensory.Terminal.input_first(term, "a") == [1, 6, 8, 10, 14, 21, 25, 29, 33, 41]
    assert Sensory.Terminal.input_first(term, "a\\") == [1, 6, 8, 10, 14, 21, 25, 29, 33, 41, 61, 64, 78, 87, 91]
    assert Sensory.Terminal.input_first(term, "test") == [5, 9, 11, 12, 16, 18, 25, 29, 38, 39, 51, 52, 54, 57, 59, 61, 62, 63, 68, 70, 71, 75, 79, 82, 90, 94, 107, 108, 109, 110, 114, 121, 125, 128, 133, 155, 159, 161, 162, 166, 168, 175, 179, 188, 189]
  end
end
