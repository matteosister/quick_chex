defmodule QuickChex.CustomGenerators do
  def even_number do
    1..100
    |> Enum.filter(&(rem(&1, 2) === 0))
    |> Enum.random
  end

  def even_numbers do
    0..10
    |> Enum.map(fn _ -> even_number end)
  end
end
