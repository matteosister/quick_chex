defmodule QuickChexTest do
  use ExUnit.Case
  doctest QuickChex
  use QuickChex

  test "the truth" do
    assert 2 + 2 == 4
  end

  property "the truth 2" do
    assert 1 + 1 == 2
  end
end
