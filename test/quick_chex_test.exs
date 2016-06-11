defmodule QuickChexTest do
  use ExUnit.Case
  doctest QuickChex
  use QuickChex

  defmodule TestModule do
    def append(s, what \\ "?"), do: s <> what
    def sum(n1, n2), do: n1 + n2
  end

  property "basic example with 'generators' keyword" do
    generators test1: binary(1, 100)

    assert is_binary(TestModule.append(test1))
  end

  property "change the iterations number with 'iterations'" do
    iterations 20
    generators num1: non_neg_integer, num2: non_neg_integer

    assert num1 < (TestModule.sum(num1, num2))
    assert num2 < (TestModule.sum(num1, num2))
  end

  property "use 'implies' to limit the test properties" do
    iterations 20
    generators num1: non_neg_integer(1, 10), num2: non_neg_integer(1, 10)
    implies num1 <= 5 and num2 > 5

    assert num1 < num2
    num3 = num1 + num2
    assert num3 > 5
  end

  property "list generator" do
    iterations 20
    generators list1: list(non_neg_integer, 10, 20)

    assert length(list1) >= 10
    assert length(list1) <= 20
  end

  property "list generator, with args" do
    iterations 20
    generators list1: list(non_neg_integer(1, 10), 10, 20)

    assert length(list1) >= 10
    assert length(list1) <= 20
    assert Enum.all? list1, fn (v) -> 1 <= v and v <= 10 end
  end

  property "list with implies" do
    iterations 5
    generators list1: list(non_neg_integer, 10)
    implies Enum.all?(list1, &(&1 >= 50))

    assert length(list1) === 10
    assert Enum.all? list1, fn (v) -> v >= 50 end
  end
end
