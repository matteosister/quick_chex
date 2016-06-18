defmodule QuickChex.EnumExamplesTest do
  use QuickChex

  describe "sorting" do
    property :enum_sort, l do
      assert l |> Enum.sort == l |> Enum.sort |> Enum.sort
    end

    check :enum_sort,
      with: [list_of(:binary, 0, 10)]
  end

  describe "reversing" do
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
end
