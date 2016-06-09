defmodule QuickChex.Generators do
  @moduledoc """
  a module to generate data to be used in properties
  """
  def int do
    1..100
    |> Enum.random
  end

  def binary(size) do
    String.duplicate("a", size)
  end
  def binary(from, to) do
    String.duplicate("a", Enum.random(from..to))
  end
end
