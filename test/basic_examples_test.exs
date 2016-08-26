defmodule QuickChex.BasicExamplesTest do
  use ExUnit.Case, async: true
  use QuickChex

  defmodule Test do
    def add(a, b), do: a + b
    def concat(a, b), do: a <> b
    def multiply(a, b, c), do: a * b * c
    def sum_tuple({a, b}), do: a + b
    def join_lists(list1, list2), do: list1 ++ list2
  end

  describe "Test.add" do
    property :add_commutative, a, b do
      assert Test.add(a, b) === Test.add(b, a)
    end

    check :add_commutative,
      with: [non_neg_integer, non_neg_integer],
      only_if: fn num1, num2 -> num1 > num2 end

    check :add_commutative, "add commutative 2",
      with: [non_neg_integer, non_neg_integer],
      only_if: fn num1, num2 -> num1 > num2 end

    check :add_commutative, "add rationals",
      with: [non_neg_rational, non_neg_rational]

    property :add_zero_returns_the_same_value, a do
      assert a === Test.add(a, 0)
    end

    check :add_zero_returns_the_same_value,
      with: [non_neg_integer]

    property :add_twice_one_is_equal_to_two, num do
      r1 = num |> Test.add(1) |> Test.add(1)
      r2 = num |> Test.add(2)
      assert r1 === r2
    end

    check :add_twice_one_is_equal_to_two,
      with: [non_neg_integer]

    check :add_twice_one_is_equal_to_two, "rationals",
      with: [non_neg_rational]
  end

  describe "Test.concat" do
    property :concat_the_same_string_is_commutative, value1, value2 do
      assert Test.concat(value1, value2) === Test.concat(value2, value1)
    end

    check :concat_the_same_string_is_commutative,
      with: fn ->
        value = binary(10)
        [value, value]
      end
  end

  describe "Test.multiply" do
    property :multiply_commutative, v1, v2, v3 do
      assert Test.multiply(v1, v2, v3) === Test.multiply(v3, v2, v1)
      assert Test.multiply(v1, v2, v3) === Test.multiply(v2, v3, v1)
      assert Test.multiply(v1, v2, v3) === Test.multiply(v1, v3, v2)
    end

    check :multiply_commutative,
      with: [non_neg_integer, non_neg_integer, non_neg_integer]

  end

  describe "Test.sum_tuple" do
    property :sum_tuple, {a, b} do
      assert Test.add(a, b) === Test.add(b, a)
    end

    check :sum_tuple,
      with: [{non_neg_integer, non_neg_integer}]

    check :sum_tuple, "rationals",
      with: [{non_neg_rational, non_neg_rational}]
  end

  describe "Test.join_lists" do
    property :join_lists, list1, list2 do
      res = Test.join_lists(list1, list2)
      assert length(list1) + length(list2) === length(res)
      assert Enum.all? list1, &(&1 in res)
      assert Enum.all? list2, &(&1 in res)
    end

    check :join_lists,
      with: [list_of({:binary, [1]}, 0, 1), list_of({:binary, [1]}, 0, 10)]
  end
end
