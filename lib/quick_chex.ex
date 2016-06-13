defmodule QuickChex do
  @moduledoc """
  QuickChex is a library to do property based testing
  """
  import QuickChex.Generators

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators
      ExUnit.plural_rule("property", "properties")

      Module.register_attribute __MODULE__, :qc_properties, accumulate: true
    end
  end

  @doc """
  define a property with one generated parameter
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
  define a property with two generated parameters
  """
  defmacro property(name, param1, param2, do: contents) do
    contents = Macro.escape(contents)
    param1 = Macro.escape(param1)
    param2 = Macro.escape(param2)
    quote bind_quoted: [name: name, param1: param1, param2: param2, contents: contents] do
      @qc_properties name
      func_name = "quick_chex_property_#{name}" |> String.to_atom
      def unquote(func_name)(unquote(param1), unquote(param2)) do
        unquote(contents)
      end
    end
  end

  @doc """
  check a property by giving a property name and a keyword list of settings
  """
  defmacro check(name, check_name \\ nil, settings) do
    generators = settings
    |> Keyword.get(:with)
    |> Macro.escape
    iterations = settings[:iterations] || 10
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

      # if Module.defines?(__MODULE__, {func_name, length(generators)}) do
      # else
      #   test_func_name = ExUnit.Case.register_test(__ENV__, :property, name, [])
      #   def unquote(test_func_name)(_) do
      #     property_name = unquote(name) |> to_string
      #     raise missing_property_error_message(property_name, @qc_properties)
      #   end
      # end
    end
  end

  def register_name(name, nil, iteration_num) do
    "#{name} - iteration #{iteration_num}"
  end
  def register_name(name, check_name, iteration_num) do
    "#{name} - #{check_name} - iteration #{iteration_num}"
  end

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

  # def function_setup_correct(module, func_name, generators) do
  #   IO.inspect func_name
  #   IO.inspect length(generators)
  #   func_exists = module.__info__(:functions)
  #   |> IO.inspect
  #   |> Enum.any?(fn {name, arity} ->
  #     func_name === name and length(generators) === arity
  #   end)
  #   #|> IO.inspect
  #   if func_exists do
  #     {:ok, nil}
  #   else
  #     {:error, missing_property_error_message(func_name, Module.get_attribute(module, :qc_properties))}
  #   end
  # end

  # def missing_property_error_message(property_name, properties) do
  #   msg = "You are trying to check a property named :#{property_name} "
  #     <> "but a property with such name is not defined."
  #   {similar, _} = properties
  #   |> Enum.map(&to_string/1)
  #   |> Enum.map(&({&1, String.jaro_distance(&1, property_name)}))
  #   |> Enum.max_by(fn {_, distance} -> distance end)
  #
  #   msg <> " Do you mean :#{similar}?"
  # end
end
