defmodule QuickChex do
  @moduledoc """
  QuickChex is a library to do property based testing
  """

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
  check a property with the given settings
  """
  defmacro check(name, settings) do
    generators = settings
    |> Keyword.get(:with)
    |> Macro.escape
    iterations = settings[:iterations] || 10

    quote bind_quoted: [name: name, settings: settings, generators: generators,
    iterations: iterations] do
      func_name = "quick_chex_property_#{name}" |> String.to_atom
      1..iterations
      |> Enum.map(fn num ->
        test_func_name = ExUnit.Case.register_test(__ENV__, :property,
          "#{name} - iteration #{num}", [])
        def unquote(test_func_name)(_) do
          generators = unquote(generators)
          if is_function(generators) do
            apply(__MODULE__, unquote(func_name), generators.())
          else
            apply(__MODULE__, unquote(func_name), generators)
          end
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

  @doc false
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

  @doc false
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
