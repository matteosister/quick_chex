defmodule QuickChexTest do
  use ExUnit.Case
  doctest QuickChex
  use QuickChex

  setup do
    a = 200
    {:ok, a: a}
  end

  property "the truth 3" do
    iterations 100
    generators test1: binary(1, 100), test2: binary(1, 100)
    implies String.length(test1) < String.length(test2)
    assert String.length(test1) < String.length(test2)
  end
end
