defmodule QuickChex.CustomGenerators do
  def even_number do
    1..1000
    |> Enum.filter(&(rem(&1, 2) === 0))
    |> Enum.random
  end

  def even_numbers do
    0..100
    |> Enum.map(fn _ -> even_number end)
  end
end
