defmodule QuickChex do
  alias QuickChex.PropertyTest

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators

      ExUnit.plural_rule("property", "properties")
    end
  end

  defmacro property(message, do: contents) do
    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: [message: message, contents: contents] do
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
        v = {var_name, context, nil}, acc ->
          if PropertyTest.has_property?(property_test, var_name) do
            {v, acc ++ [var_name]}
          else
            {v, acc}
          end
        v, acc -> {v, acc}
      end)
      context_vars = Enum.uniq(context_vars)

      property_test
      |> PropertyTest.get_values(context_vars)
      |> Enum.reduce(1, fn iteration_values, num ->
        contents = Macro.postwalk(contents, fn
          v = {var_name, context, nil} ->
            if PropertyTest.has_property?(property_test, var_name) do
              Keyword.get(iteration_values, var_name)
            else
              v
            end
          v -> v
        end)
        name = ExUnit.Case.register_test(__ENV__, :property, message <> to_string(num), [])
        def unquote(name)(_), do: unquote(contents)
        num + 1
      end)
    end
  end


end
