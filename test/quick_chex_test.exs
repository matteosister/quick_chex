defmodule QuickChexTest do
  use ExUnit.Case
  doctest QuickChex
  use QuickChex

  setup do
    a = 200
    {:ok, a: a}
  end

  property "the truth 2", context, generators: [test1: int, test2: int], iterations: 50 do
    assert context[:a] > test2
  end

  property "the truth 3", generators: [test1: binary(9), test2: binary(10)], iterations: 50 do
    assert String.length(test1) < String.length(test2)
  end
end
