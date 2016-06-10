defmodule QuickChex.Generators do
  @moduledoc """
  a module to generate data to be used in properties
  """
  def non_neg_integer do
    non_neg_integer(1, 100)
  end

  def non_neg_integer(min, max) do
    min..max
    |> Enum.random
  end

  def binary do
    String.duplicate("q", Enum.random(1..100))
  end
  def binary(size) do
    String.duplicate("q", size)
  end
  def binary(min_size, max_size) do
    String.duplicate("q", Enum.random(min_size..max_size))
  end
end
