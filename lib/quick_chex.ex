defmodule QuickChex do
  @moduledoc """
  main module with the main macros that you should use when writing
  tests.

  Check the docs for the single methods for examples and use cases.
  """
  import QuickChex.Generators, warn: false

  @default_iterations_number Application.get_env(:quick_chex, :iterations, 100)

  @doc """
  add `use QuickChex` at the top of your ExUnit test module

  ## Example

  ```
  defmodule MyModuleTest do
    use ExUnit.Case, async: true
    use QuickChex # <- add this!
  end
  ```
  """
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators
      ExUnit.plural_rule("property", "properties")

      Module.register_attribute __MODULE__, :qc_properties, accumulate: true
    end
  end

  @doc """
  specify a property with a single generate parameter

  A property has a `name` to be identified by checks, a `param1` that will
  be generated, and a body to specify the requirements

  ## Example

  for a **negate** property of a `Test.negate/1` function you could write a
  property like this:

  ```
  property :negate, value do
    assert not value === Test.negate(value)
  end

  property :negate_two_time_means_doing_nothing, value do
    res = value
    |> Test.negate
    |> Test.negate
    assert value === res
  end
  ```
  """
  defmacro property(name, param1, do: contents) do
    contents = Macro.escape(contents)
    param1 = Macro.escape(param1)
    quote bind_quoted: [name: name, param1: param1, contents: contents] do
      @qc_properties name
      func_name = "quick_chex_property_#{name}" |> String.to_atom
      def unquote(func_name)(unquote(param1)) do
        unquote(contents)
      end
    end
  end

  @doc """
  same as property/2 with two generated parameters

  ## Example

  a property for the Test.add/2 function

  ```
  property :add_is_commutative, n1, n2 do
    assert Test.add(n1, n2) === Test.add(n2, n1)
  end
  ```
  """
  defmacro property(name, param1, param2, do: contents) do
    contents = Macro.escape(contents)
    param1 = Macro.escape(param1)
    param2 = Macro.escape(param2)
    quote bind_quoted: [name: name, param1: param1, param2: param2,
    contents: contents] do
      @qc_properties name
      func_name = "quick_chex_property_#{name}" |> String.to_atom
      def unquote(func_name)(unquote(param1), unquote(param2)) do
        unquote(contents)
      end
    end
  end

  @doc """
  same as property/2 with three generated parameters
  """
  defmacro property(name, param1, param2, param3, do: contents) do
    contents = Macro.escape(contents)
    param1 = Macro.escape(param1)
    param2 = Macro.escape(param2)
    param3 = Macro.escape(param3)
    quote bind_quoted: [name: name, param1: param1, param2: param2,
    param3: param3, contents: contents] do
      @qc_properties name
      func_name = "quick_chex_property_#{name}" |> String.to_atom
      def unquote(func_name)(unquote(param1), unquote(param2),
      unquote(param3)) do
        unquote(contents)
      end
    end
  end

  @doc """
  check a property by giving the property name and a list of settings
  """
  defmacro check(name, check_name \\ nil, settings) do
    generators = settings
    |> Keyword.get(:with)
    |> Macro.escape
    iterations = settings[:iterations] || @default_iterations_number
    only_if = settings[:only_if]

    quote bind_quoted: [name: name, check_name: check_name, settings: settings,
    generators: generators, iterations: iterations, only_if: only_if] do
      func_name = "quick_chex_property_#{name}" |> String.to_atom
      1..iterations
      |> Enum.map(fn num ->
        test_func_name = ExUnit.Case.register_test(__ENV__, :property,
          register_name(name, check_name, num), [])
        args = calculate_args(generators, only_if)
        def unquote(test_func_name)(_) do
          apply(__MODULE__, unquote(func_name), unquote(args))
        end
      end)
    end
  end

  @doc false
  def register_name(name, nil, iteration_num) do
    "#{name} - iteration #{iteration_num}"
  end
  def register_name(name, check_name, iteration_num) do
    "#{name} - #{check_name} - iteration #{iteration_num}"
  end

  @doc false
  def calculate_args(generators = {:fn, _, _}, _) do
    {func, _} = Code.eval_quoted(generators, [], __ENV__)
    func.()
  end
  def calculate_args(generators, nil) do
    {values, _} = Code.eval_quoted(generators, [], __ENV__)
    values
  end
  def calculate_args(generators, check_function) do
    do_calculate_args(:next, generators, check_function)
  end
  defp do_calculate_args({:ok, values}, _, _), do: values
  defp do_calculate_args(:next, generators, check_function) do
    {values, _} = Code.eval_quoted(generators, [], __ENV__)
    res = if apply(check_function, values) do
      {:ok, values}
    else
      :next
    end
    do_calculate_args(res, generators, check_function)
  end
end
