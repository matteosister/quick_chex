defmodule QuickChex.QuickChexTest do
  use ExUnit.Case, async: true
  use QuickChex

  defmodule Test do
    def add(a, b), do: a + b
    def concat(a, b), do: a <> b
  end

  describe "add" do
    property :add_commutative, a, b do
      assert Test.add(a, b) === Test.add(b, a)
    end

    check :add_commutative,
      with: [non_neg_integer, non_neg_integer],
      iterations: 100

    property :add_zero_returns_the_same_value, a do
      assert a === Test.add(a, 0)
    end

    check :add_zero_returns_the_same_value,
      with: [non_neg_integer],
      iterations: 100

    property :add_twice_one_is_equal_to_two, num do
      r1 = num |> Test.add(1) |> Test.add(1)
      r2 = num |> Test.add(2)
      assert r1 === r2
    end

    check :add_twice_one_is_equal_to_two,
      with: [non_neg_integer],
      iterations: 100
  end

  property :concat_the_same_string_is_commutative, value1, value2 do
    assert Test.concat(value1, value2) === Test.concat(value2, value1)
  end

  check :concat_the_same_string_is_commutative,
    with: fn ->
      value = binary(10)
      [value, value]
    end,
    iterations: 100
end
