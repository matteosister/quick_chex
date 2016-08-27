# Generators

Generators are the way to tell *QuickChex* how to forge the data to be tested.

They are very important and the core concept of propery based testing.

In QuickChex the generators are the things that stay in the **with:** element
of the check function invocation.

Let's see an example. We will create a property for a function that sums even
numbers

    defmodule SumTest do
      use ExUnit.Case, async: true
      use QuickChex

      property :sum, num1, num2 do
        assert rem(num1 + num2, 2) === 0
      end
    end
