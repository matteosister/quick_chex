defmodule QuickChex.Formatter do
  @moduledoc """
  QuickChex formatter
  """
  use GenEvent

  def handle_event({:test_finished, test = %ExUnit.Test{state: {:failed, failures}, tags: %{args: args}}}, _) do
    IO.puts "Failed params:\n"
    args
    |> Stream.map(&inspect/1)
    |> Enum.each(&IO.puts/1)
    {:ok, nil}
  end

  def handle_event(_, _), do: {:ok, nil}
end
