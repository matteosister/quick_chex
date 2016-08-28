defmodule QuickChex.CustomGeneratorsTest do
  use ExUnit.Case, async: true
  use QuickChex

  property :add_even_numbers, list do
    assert rem(Enum.sum(list), 2) === 0
  end

  check :add_even_numbers,
    with: fn ->
      [QuickChex.CustomGenerators.even_numbers]
    end,
    iterations: 1_000
end
