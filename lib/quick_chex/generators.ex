defmodule QuickChex.Generators do
  @moduledoc """
  a module to generate data to be used in properties
  """

  @doc """
  generates a non negative integer number between 0 and 1_000_000
  """
  def non_neg_integer do
    non_neg_integer(0, 1_000_000)
  end

  @doc """
  generates a non negative integer bound to a min and a max value

  iex> num = QuickChex.Generators.non_neg_integer(1, 2)
  ...> num >= 1 and num <= 2
  true
  """
  def non_neg_integer(min_value, max_value) do
    min_value..max_value
    |> Enum.random
  end

  def binary do
    String.duplicate("q", Enum.random(1..100))
  end
  def binary(size) do
    binary(size, size)
  end
  def binary(min_size, max_size) do
    String.duplicate("q", pick_number(min_size, max_size))
  end

  def list(generator, size) do
    list(generator, size, size)
  end

  def list(generator, min_size, max_size) do
    1..pick_number(min_size, max_size)
    |> Enum.map(fn _ -> call_generator(generator) end)
  end

  defp call_generator({name, _, args}) when is_nil(args) do
    apply(__MODULE__, name, [])
  end
  defp call_generator({name, _, args}), do: apply(__MODULE__, name, args)

  defp pick_number(min_value, max_value) do
    min_value..max_value |> Enum.random
  end
end
