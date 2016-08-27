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
end
