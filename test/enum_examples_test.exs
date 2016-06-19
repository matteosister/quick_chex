defmodule QuickChex.EnumExamplesTest do
  use QuickChex

  describe "Enum.sort" do
    property :enum_sort, l do
      assert l |> Enum.sort == l |> Enum.sort |> Enum.sort
    end

    check :enum_sort,
      with: [list_of(:binary, 0, 10)]
  end

  describe "Enum.reverse" do
    property :enum_reverse, l do
      assert l |> Enum.reverse |> Enum.reverse == l
    end

    check :enum_reverse,
      with: [list_of(:binary, 0, 10)]

    property :wrong_reverse, l do
      assert l |> Enum.reverse == l
    end

    check :wrong_reverse, "this is true for lists of one element",
      with: [list_of({:binary, [1, 4]}, 1)]
  end

  describe "Enum.map" do
    property :map_with_identity, l do
      assert l == Enum.map l, &(&1)
    end

    check :map_with_identity,
      with: [random_list]

    property :integer_list_negative, l do
      res = l
      |> Enum.map(&(&1 * -1))
      |> Enum.sum
      assert res + Enum.sum(l) === 0
    end

    check :integer_list_negative,
      with: [list_of({:non_neg_integer, [0, 100]}, 100)]
  end
end
