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
    pick_number(min_value, max_value)
  end

  @doc """
  generates a binary of random size, between 0 and 100
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
    do_binary(size - 1, acc ++ [letter])
  end

  @doc """
  generates a list of size `size` and fill it with the generator supplied

  ## Examples

      iex> import QuickChex.Generators
      ...> list = list_of(:non_neg_integer, 10)
      ...> length(list) === 10
      true

      iex> import QuickChex.Generators
      ...> list = list_of({:non_neg_integer, [1, 2]}, 10)
      ...> Enum.all?(list, &is_number/1)
      true
  """
  def list_of(generator, size) do
    list_of(generator, size, size)
  end

  @doc """
  same as list/2, but generate it with a size between `min_size` and `max_size`
  """
  def list_of(generator, min_size, max_size) do
    min_size
    |> pick_number(max_size)
    |> do_list_of([], generator)
  end

  defp do_list_of(0, acc, _), do: acc
  defp do_list_of(size, acc, generator) do
    do_list_of(size - 1, acc ++ [call_generator(generator)], generator)
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

  @doc """
  returns an alphabet letter in binary format

  only letters from A to Z uppercase and lowercase

  ## Examples

      iex> Regex.match?(~r/[a-zA-Z]{1}/, QuickChex.Generators.letter)
      true
  """
  def letter, do: [one_of(Enum.concat(?A..?Z, ?a..?z))] |> to_string

  @doc """
  returns a lowercase letter

  ## Examples

      iex> Regex.match?(~r/[a-z]{1}/, QuickChex.Generators.lowercase_letter)
      true
  """
  def lowercase_letter, do: [one_of(?a..?z)] |> to_string

  @doc """
  returns an uppercase letter

  ## Examples

      iex> Regex.match?(~r/[A-Z]{1}/, QuickChex.Generators.uppercase_letter)
      true
  """
  def uppercase_letter, do: [one_of(?A..?Z)] |> to_string

  @doc """
  returns a number from 0 to 9

  ## Examples

      iex> Regex.match?(~r/\\d{1}/, QuickChex.Generators.number |> to_string)
      true
  """
  def number, do: one_of(0..9)

  @doc """
  returns a binary sequence with the specified generators

  ## Examples

      iex> v = QuickChex.Generators.binary_sequence([letter: 2, number: 3])
      ...> Regex.match?(~r/[A-Za-z]{2}\\d{3}/, v)
      true

      iex> v = QuickChex.Generators.binary_sequence([lowercase_letter: 10,
      ...> number: 3])
      ...> Regex.match?(~r/[a-z]{10}\\d{3}/, v)
      true

      iex> v = QuickChex.Generators.binary_sequence([lowercase_letter: 3,
      ...> uppercase_letter: 3])
      ...> Regex.match?(~r/[a-z]{3}[A-Z]{3}/, v)
      true
  """
  def binary_sequence(generators), do: generators |> do_sequence([])

  defp do_sequence([], acc) do
    acc
    |> Enum.flat_map(&(&1))
    |> Enum.map(&to_string/1)
    |> Enum.join
  end
  defp do_sequence([{generator, num} | others], acc) do
    do_sequence(others, acc ++ [call_generators(generator, num)])
  end

  defp call_generator({name, _, nil}) do
    apply(__MODULE__, name, [])
  end
  defp call_generator({name, _, args}), do: apply(__MODULE__, name, args)
  defp call_generator({name, args}), do: apply(__MODULE__, name, args)
  defp call_generator(value) when is_atom(value), do: apply(__MODULE__, value, [])
  defp call_generator(value), do: value

  defp call_generators(generator, num) do
    1..num |> Enum.map(fn _ -> call_generator(generator) end)
  end

  defp pick_number(min_value, max_value) do
    min_value..max_value |> Enum.random
  end
end
