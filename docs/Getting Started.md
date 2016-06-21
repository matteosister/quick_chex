# Getting Started

## Introduction

> Property-based tests make statements about the output of your code based on
> the input, and these statements are verified for many different possible
> inputs.

This library is a tool to automate property-based testing within ExUnit

**QuickChex requires Elixir 1.3.0**

## How to use

Create a test module as you normally do with ExUnit

    defmodule EnumTest do
      use ExUnit.Case, async: true
      use QuickChex # <- add this line to import all the QuickChex features
    end

## Let's test the Enum module

One of the advantages of property-based testing is that it force you to think
about the functionality you are testing and not at the implementation.

Let's take for example the *Enum.sort/1* function from the standard library.

We can reason about it, and end up by thinking: *sorting should be idempotent!*

Sorting a list one time should be the same as sorting 2 times. So we can write
our first property

    defmodule EnumTest do
      use ExUnit.Case, async: true
      use QuickChex

      property :double_sort, list do
        assert list |> Enum.sort === list |> Enum.sort |> Enum.sort
      end
    end

we are defining a property by giving it the name *:double_sort* (it could also
be a string), passing the variable we will test (a list) and then implement a
body with the assertion we were expecting: **sorting one time is the same as
sorting two times**

Now it's time to check the property

    defmodule EnumTest do
      use ExUnit.Case, async: true
      use QuickChex

      property :double_sort, list do
        assert list |> Enum.sort === list |> Enum.sort |> Enum.sort
      end

      check :double_sort,
        with: [list_of(:binary, 5, 10)],
        iterations: 50
    end

We define a **check** by passing the property name (:double_sort) and the
[generators](https://hexdocs.pm/quick_chex/QuickChex.Generators.html) to be
used. Here we are creating a list_of random binary string with 5 to 10 elements.
Then we specify the number of iterations.

We are all set! We now just need to run **mix test** from the console

    $ mix test

    ..................................................

    Finished in 0.7 seconds
    50 properties, 0 failures

we have 50 passing tests with random list of strings. Easy!
