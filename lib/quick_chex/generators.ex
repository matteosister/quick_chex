defmodule QuickChex.Generators do
  @moduledoc """
  a module to generate data to be used in properties
  """

  @type generator :: {atom, list} | atom

  @doc """
  generates a non negative integer number between 0 and 1_000_000

  ## How to use

      check :the_property,
        with: [non_neg_integer]

  ## Examples

      iex> num = QuickChex.Generators.non_neg_integer
      ...> is_number(num) and num >= 0 and num <= 1_000_000
      true
  """
  @spec non_neg_integer :: integer
  def non_neg_integer do
    non_neg_integer(0, 1_000_000)
  end

  @doc """
  generates a non negative integer bound to a min and a max value

  ## How to use

      check :the_property,
        with: [non_neg_integer(1,20)]

  ## Examples

      iex> num = QuickChex.Generators.non_neg_integer(1, 2)
      ...> is_number(num) and num >= 1 and num <= 2
      true
  """
  @spec non_neg_integer(integer, integer) :: integer
  def non_neg_integer(min_value, max_value) do
    min_value
    |> pick_number(max_value)
    |> abs
  end

  @doc """
  generates a non negative rational bound to a min and a max value
  using :rand.uniform for the decimal representation

  ## How to use

      check :the_property,
        with: [non_neg_rational]

  ### Examples

    iex> num = QuickChex.Generators.non_neg_rational
    ...> is_number(num) and num >= 0 and num <= 1_000_000
    true
  """
  @spec non_neg_rational :: float
  def non_neg_rational do
    non_neg_rational(0, 1_000_000, 2)
  end

  @doc """
  generates a non negative rational of a given precision
  bound to a min and a max value, using :rand.uniform
  for the decimal representation

  ## How to use

      check :the_property,
        with: [non_neg_rational(1, 20)] # from 1 to 20

      check :another_property,
        with: [non_neg_rational(1, 20, 5)] # from 1 to 20 with precision of 5

  ### Examples

    iex> num = QuickChex.Generators.non_neg_rational(1, 5, 2)
    ...> is_number(num) and num >= 0 and num <= 1_000_000
    true
  """
  @spec non_neg_rational(integer, integer, integer) :: float
  def non_neg_rational(min_value, max_value, max_precision \\ 2) do
    min_value
    |> Kernel.+(max_value - min_value)
    |> Kernel.*(:rand.uniform)
    |> Float.round(max_precision)
  end

  @doc """
  generates a binary of random size, between 0 and 100

  ## How to use

      check :the_property,
        with: [binary]
  """
  @spec binary :: binary
  def binary do
    binary(non_neg_integer(0, 100))
  end

  @doc """
  generates a binary of the given size

  ## How to use

      check :the_property,
        with: [binary(10)]
  """
  @spec binary(integer) :: binary
  def binary(size) do
    binary(size, size)
  end

  @doc """
  generates a binary of size between `min_size` and `max_size`

  ## How to use

      check :the_property,
        with: [binary(1,1_000)]
  """
  @spec binary(integer, integer) :: binary
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
  generates a random list of randomly generated values. The size is between 0
  and 10

  ## How to use

      check :the_property,
        with: [random_list]
  """
  @spec random_list :: list
  def random_list do
    random_list(non_neg_integer(1, 5), non_neg_integer(5, 10))
  end

  @doc """
  generates a random list of randomly generated values with the provided size

  ## How to use

      check :the_property,
        with: [random_list(2)]
  """
  @spec random_list(integer) :: list
  def random_list(size) do
    random_list(size, size)
  end

  @doc """
  generates a random list of randomly generated values with a size between the
  min and max sizes provided

  ## How to use

      check :the_property,
        with: [random_list(2, 10)]
  """
  @spec random_list(integer, integer) :: list
  def random_list(min_size, max_size) do
    1..pick_number(min_size, max_size)
    |> Enum.map(fn _ -> random_generator end)
    |> Enum.map(&call_generator/1)
  end


  @doc """
  generates a list of random size (0..1_000) and fill it with the supplied
  generator

  ## How to use

      check :the_property,
        with: [list_of(:binary)]

      check :another_property,
        with: [list_of({:non_neg_integer, [1, 4]})]
  """
  @spec list_of(generator) :: list
  def list_of(generator) do
    list_of(generator, 0, 1_000)
  end

  @doc """
  generates a list of size `size` and fill it with the supplied generator

  ## How to use

      check :the_property,
        with: [list_of(:binary, 10)]

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
  @spec list_of(generator, integer) :: list
  def list_of(generator, size) do
    list_of(generator, size, size)
  end

  @doc """
  same as list/2, but generate it with a size between `min_size` and `max_size`

  ## How to use

      check :the_property,
        with: [list_of(:binary, 10, 20)]
  """
  @spec list_of(generator, integer, integer) :: list
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

  ## How to use

      check :the_property,
        with: [bool]
  """
  @spec bool :: boolean
  def bool do
    one_of [true, false]
  end

  @doc """
  returns one of the given values

  ## How to use

      check :the_property,
        with: [one_of(1, 2, 3)] # exactly 1, 2 or 3

  ## Examples

      iex> QuickChex.Generators.one_of([1])
      1

      iex> r = QuickChex.Generators.one_of([1, 2])
      ...> r === 1 or r === 2
      true
  """
  @spec one_of(list) :: any
  def one_of(list), do: list |> Enum.random

  @doc """
  returns an alphabet letter in binary format

  only letters from A to Z uppercase and lowercase

  ## How to use

      check :the_property,
        with: [letter]

  ## Examples

      iex> Regex.match?(~r/[a-zA-Z]{1}/, QuickChex.Generators.letter)
      true
  """
  @spec letter :: binary
  def letter, do: [one_of(Enum.concat(?A..?Z, ?a..?z))] |> to_string

  @doc """
  returns a lowercase letter

  ## How to use

      check :the_property,
        with: [lowercase_letter]

  ## Examples

      iex> Regex.match?(~r/[a-z]{1}/, QuickChex.Generators.lowercase_letter)
      true
  """
  @spec lowercase_letter :: binary
  def lowercase_letter, do: [one_of(?a..?z)] |> to_string

  @doc """
  returns an uppercase letter

  ## How to use

      check :the_property,
        with: [uppercase_letter]

  ## Examples

      iex> Regex.match?(~r/[A-Z]{1}/, QuickChex.Generators.uppercase_letter)
      true
  """
  @spec uppercase_letter :: binary
  def uppercase_letter, do: [one_of(?A..?Z)] |> to_string

  @doc """
  returns a number from 0 to 9

  ## How to use

      check :the_property,
        with: [number]

  ## Examples

      iex> Regex.match?(~r/\\d{1}/, QuickChex.Generators.number |> to_string)
      true
  """
  @spec number :: integer
  def number, do: one_of(0..9)

  @doc """
  generate a binary sequence with a pattern

  with this function you can generate a sequence of characters by invoking
  other generators

  ## How to use

      check :the_property,
        with: [binary_sequence([number: 1, lowercase_letter: 2, number: 2])]

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
  @spec binary_sequence([generator]) :: binary
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
  defp call_generator(value) when is_atom(value) do
    apply(__MODULE__, value, [])
  end
  defp call_generator(value) do
    raise "You have passed the value #{inspect value} as a generator,
      You should pass an :atom for calling a generator without arguments,
      or a tuple with an atom and a list of args, to call a generator with
      params. For example the tuple {:non_neg_integer, [1, 20]} will generate a
      non negative integer between 1 and 20"
  end

  defp call_generators(generator, num) do
    1..num |> Enum.map(fn _ -> call_generator(generator) end)
  end

  defp pick_number(min_value, max_value) do
    min_value..max_value |> Enum.random
  end

  defp random_generator do
    [:binary, :non_neg_integer, {:list_of, [:binary, 0, 10]}, :bool]
    |> Enum.random
  end
end
