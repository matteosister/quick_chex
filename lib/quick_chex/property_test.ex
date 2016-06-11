defmodule QuickChex.PropertyTest do
  @moduledoc false

  alias QuickChex.PropertyTest

  defstruct \
    message: nil,
    iterations: 1,
    generators: [],
    implies: []

  def new(message) do
    %PropertyTest{message: message}
  end

  def add_generators(property_test, generators) do
    %{property_test | generators: generators}
  end

  def add_implies(property_test, implies) do
    %{property_test | implies: implies}
  end

  def set_iterations(property_test, iterations) do
    %{property_test | iterations: iterations}
  end

  def has_property?(%PropertyTest{generators: generators}, name) do
    generators
    |> Keyword.has_key?(name)
  end

  def get_values(property_test = %PropertyTest{iterations: iterations}, var_names) do
    1..iterations
    |> Enum.map(fn _ -> do_get_values(property_test, var_names) end)
  end

  defp do_get_values(property_test = %PropertyTest{implies: implies}, var_names) do
    if implies === [] do
      var_names
      |> Enum.map(&({&1, get_value(property_test, &1)}))
    else
      {contents, values} = Macro.postwalk(implies, [], fn
        {var, _, nil}, acc ->
          value = get_value(property_test, var)
          {value, acc ++ [{var, value}]}
        v, acc -> {v, acc}
      end)
      {res, _} = Code.eval_quoted(contents)
      if res do
        values
      else
        do_get_values(property_test, var_names)
      end
    end
  end

  def get_value(%PropertyTest{generators: generators}, var_name) do
    {_, {generator, _, args}} = generators
    |> Enum.find(fn {name, _} -> name === var_name end)
    if is_nil(args) do
      apply(QuickChex.Generators, generator, [])
    else
      apply(QuickChex.Generators, generator, args)
    end
  end
end
