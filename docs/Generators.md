# Generators

Generators are the way to tell *QuickChex* how to forge the data to be tested.

They are very important and the core concept of propery based testing.

In QuickChex the generators are the things that stay in the **with:** element
of the check function invocation.

## How to use them

In the `QuickChex.Generators` module there are some examples of how to use them.

There are some things to understand.

You can call any of the generators in the `QuickChex.Generators` module inside
a **with:** element, exactly like normal elixir code.

There are some *higher order* generators like `QuickChex.Generators.list_of/1`
that accepts another generator as argument. In this case you have to use the
generator name as an atom, or a tuple if you want to pass arguments. Here is
an example:

    check :the_property,
      with: [list_of(:non_neg_integer)] # list of non negative integers

    check :another_property,
      with: [list_of({:non_neg_integer, [1,10]})] # list of non negative integers between 1 and 10

## Custom generators

The `QuickChex.Generators` try to fill every needs about generating base data.

When the base generators are not enough, and you need to generates custom data
like structs, or really convoluted examples you can always use a closure to
generate the data you want.

The function should return a list of values, with the length of the arity of
the property you are testing.

for example:

    defmodule QuickChex.CustomGeneratorsTest do
      use ExUnit.Case, async: true
      use QuickChex

      property :add_even_numbers, list do
        assert rem(Enum.sum(list), 2) === 0
      end

      check :add_even_numbers,
        with: fn ->
          even_numbers = 0..10
          |> Enum.map(fn _ ->
            1..100
            |> Enum.filter(&(rem(&1, 2) === 0))
            |> Enum.random
          end)
          [even_numbers] # <- the property accept a single variable, list, so we return a list with a single element.
        end
    end
