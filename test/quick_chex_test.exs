defmodule QuickChex.QuickChexTest do
  use ExUnit.Case, async: true
  use QuickChex

  defmodule Test do
    def add(a, b), do: a + b
    def concat(a, b), do: a <> b
  end

  property :add_commutative, a, b do
    r1 = Test.add(a, b)
    r2 = Test.add(b, a)
    assert r1 === r2
  end

  property :add_zero, a do
    r1 = Test.add(a, 0)
    assert a === r1
  end

  property :add_twice_one_is_equal_to_two, num do
    r1 = num |> Test.add(1) |> Test.add(1)
    r2 = num |> Test.add(2)
    assert r1 === r2
  end

  check :add_commutative,
    with: [non_neg_integer, non_neg_integer],
    iterations: 100

  check :add_zero,
    with: [non_neg_integer],
    iterations: 100

  check :add_twice_one_is_equal_to_two,
    with: [non_neg_integer],
    iterations: 100
end
