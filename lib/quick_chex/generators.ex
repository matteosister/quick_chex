defmodule QuickChex.Generators do
  @moduledoc """
  a module to generate data to be used in properties
  """

  @doc """
  generates a non negative integer number between 0 and 1_000_000

  ## Examples

      iex> num = QuickChex.Generators.non_neg_integer
      ...> is_number(num) and num >= 0 and num <= 1_000_000
      true
  """
  def non_neg_integer do
    non_neg_integer(0, 1_000_000)
  end

  @doc """
  generates a non negative integer bound to a min and a max value

  ## Examples

      iex> num = QuickChex.Generators.non_neg_integer(1, 2)
      ...> is_number(num) and num >= 1 and num <= 2
      true
  """
  def non_neg_integer(min_value, max_value) do
    min_value..max_value
    |> Enum.random
  end

  @doc """
  generates a binary of random size
  """
  def binary do
    binary(non_neg_integer(0, 100))
  end

  @doc """
  generates a binary of the given size
  """
  def binary(size) do
    binary(size, size)
  end

  @doc """
  generates a binary of size between `min_size` and `max_size`
  """
  def binary(min_size, max_size) when min_size === max_size do
    min_size
    |> do_binary('')
    |> to_string
  end
  def binary(min_size, max_size) do
    min_size
    |> pick_number(max_size)
    |> do_binary('')
    |> to_string
  end

  defp do_binary(0, acc), do: acc
  defp do_binary(size, acc) do
    do_binary(size - 1, acc ++ [pick_letter])
  end

  @doc """
  generates a list of size `size` and fill it with the generator supplied

  ## Examples

      iex> import QuickChex.Generators
      ...> list = QuickChex.Generators.list({:non_neg_integer, nil, nil}, 10)
      ...> length(list) === 10
      true

      iex> import QuickChex.Generators
      ...> list = list({:non_neg_integer, nil, [1, 2]}, 10)
      ...> Enum.all?(list, &is_number/1)
      true
  """
  def list(generator, size) do
    list(generator, size, size)
  end

  @doc """
  same as list/2, but generate it with a size between `min_size` and `max_size`
  """
  def list(generator, min_size, max_size) do
    min_size
    |> pick_number(max_size)
    |> do_list([], generator)
  end

  defp do_list(0, acc, _), do: acc
  defp do_list(size, acc, generator) do
    do_list(size - 1, acc ++ [call_generator(generator)], generator)
  end

  @doc """
  a boolean value
  """
  def bool do
    one_of [true, false]
  end

  @doc """
  returns one of the given values

  ## Examples

      iex> QuickChex.Generators.one_of([1])
      1

      iex> r = QuickChex.Generators.one_of([1, 2])
      ...> r === 1 or r === 2
      true
  """
  def one_of(list), do: list |> Enum.random

  @doc false
  def call_generator({name, _, args}) when is_nil(args) do
    apply(__MODULE__, name, [])
  end
  def call_generator({name, _, args}), do: apply(__MODULE__, name, args)
  def call_generator(value), do: value

  @doc false
  def pick_number(min_value, max_value) do
    min_value..max_value |> Enum.random
  end

  @doc false
  def pick_letter, do: one_of(Enum.concat(?A..?Z, ?a..?z))
end
