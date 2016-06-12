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

  ## Examples

      iex> num = QuickChex.Generators.non_neg_integer(1, 2)
      ...> num >= 1 and num <= 2
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
  def binary(min_size, max_size) do
    ''
    |> do_binary(pick_number(min_size, max_size))
    |> Enum.join("")
  end

  defp do_binary(acc, 0), do: acc
  defp do_binary(acc, size) do
    do_binary(acc ++ [pick_letter], size - 1)
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

  defp pick_letter, do: 65..122 |> Enum.random
end
