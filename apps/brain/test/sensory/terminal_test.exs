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
end
