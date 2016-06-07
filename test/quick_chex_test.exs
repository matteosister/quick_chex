defmodule QuickChexTest do
  use ExUnit.Case
  doctest QuickChex
  use QuickChex

  test "the truth" do
    assert 2 + 2 == 4
  end

  prop "the truth 2", generators: [test1: int, test2: int], iterations: 10 do
    assert var!(test1) > var!(test2)
  end
end
