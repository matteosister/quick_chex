defmodule QuickChex.AdvancedExamplesTest do
  use ExUnit.Case, async: true
  use QuickChex

  describe "advanced generator, complex tuple" do
    property :append_adds_one_element_to_the_tuple, t, element do
      assert tuple_size(t) + 1 === tuple_size(Tuple.append(t, element))
    end

    check :append_adds_one_element_to_the_tuple,
      with: [{non_neg_integer, binary(10, 20), list_of(:non_neg_integer)}, binary]
  end

  describe "list_of generator" do
    property :list_of, list do
      assert list |> Enum.sort === list |> Enum.sort |> Enum.sort
    end

    check :list_of, "with list_of generator",
      with: [list_of({:non_neg_integer, [1,10]})]

    check :list_of, "passing a list",
      with: [[non_neg_integer(1,20)]]
  end

  describe "maps" do
    property :map, map do
      assert map === Map.take(map, [:a, :b])
    end

    check :map, "manual map",
      with: [%{a: non_neg_integer, b: binary(10)}]
  end
end
