defmodule QuickChex do
  alias QuickChex.PropertyTest

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators

      Module.register_attribute __MODULE__, :quick_chex_properties, accumulate: true

      ExUnit.plural_rule("property", "properties")

      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      #IO.inspect @quick_chex_properties
      # @quick_chex_properties
      # |> PropertyTest.get_values(context_vars)
      # |> Enum.reduce(1, fn iteration_values, num ->
      #   contents = Macro.postwalk(contents, fn
      #     {var, context, nil} -> Keyword.get(iteration_values, var)
      #     v -> v
      #   end)
      #   name = ExUnit.Case.register_test(__ENV__, :property, message <> to_string(num), [])
      #   def unquote(name)(unquote(var)) do
      #     unquote(contents)
      #   end
      #   num + 1
      # end)
    end
  end

  defmacro property(message, var \\ quote(do: _), contents) do
    contents =
      case contents do
        [do: block] ->
          quote do
            unquote(block)
            :ok
          end
        _ ->
          quote do
            try(unquote(contents))
            :ok
          end
      end

    var      = Macro.escape(var)
    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: [message: message, var: var, contents: contents] do
      property_test = PropertyTest.new(message)
      {contents, property_test} = Macro.postwalk(contents, property_test, fn
        {:iterations, _, [num]}, property_test when is_number(num) ->
          {nil, PropertyTest.set_iterations(property_test, num)}
        {:generators, _, [generators]}, property_test ->
          {nil, PropertyTest.add_generators(property_test, generators)}
        {:implies, _, [implies]}, property_test ->
          {nil, PropertyTest.add_implies(property_test, implies)}
        v, property_test ->
          {v, property_test}
      end)
      {_, context_vars} = Macro.postwalk(contents, [], fn
        v = {var, context, nil}, acc -> {v, acc ++ [var]}
        v, acc -> {v, acc}
      end)
      property_test
      |> PropertyTest.get_values(context_vars)
      |> Enum.reduce(1, fn iteration_values, num ->
        contents = Macro.postwalk(contents, fn
          {var, context, nil} -> Keyword.get(iteration_values, var)
          v -> v
        end)
        name = ExUnit.Case.register_test(__ENV__, :property, message <> to_string(num), [])
        def unquote(name)(unquote(var)) do
          unquote(contents)
        end
        num + 1
      end)
    end
  end

  defmacro iterations(number) do
    quote do
      @quick_chex_properties [iterations: unquote(number)]
    end
  end
end
