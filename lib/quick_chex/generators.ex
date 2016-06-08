defmodule QuickChex.Generators do
  @moduledoc """
  a module to generate data to be used in properties
  """
  def int do
    fn ->
      1..100
      |> Enum.random
    end
  end

  def binary(size) do
    fn ->
      String.duplicate("a", size)
    end
  end
end
