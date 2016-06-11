defmodule QuickChex do
  @moduledoc """
  QuickChex is a library for property based testing
  """

  alias QuickChex.PropertyTest

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators

      ExUnit.plural_rule("property", "properties")
    end
  end

  @doc false
  def parse_contents(contents, property_test) do
    contents
    |> Macro.postwalk(property_test, fn
      {:iterations, _, [num]}, property_test when is_number(num) ->
        {nil, PropertyTest.set_iterations(property_test, num)}
      {:generators, _, [generators]}, property_test ->
        {nil, PropertyTest.add_generators(property_test, generators)}
      {:implies, _, [implies]}, property_test ->
        {nil, PropertyTest.add_implies(property_test, implies)}
      v, property_test ->
        {v, property_test}
    end)
  end

  @doc false
  def extract_context_vars(contents, property_test) do
    # extract the context vars in the remaining content
    contents
    |> Macro.postwalk([], fn
      v = {var_name, _, nil}, acc ->
        if PropertyTest.has_property?(property_test, var_name) do
          {v, acc ++ [var_name]}
        else
          {v, acc}
        end
      v, acc -> {v, acc}
    end)
    |> elem(1)
    |> Enum.uniq
  end

  @doc """
  macro property to define property based tests inside an ExUnit module
  """
  defmacro property(message, do: contents) do
    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: [message: message, contents: contents] do
      property_test = PropertyTest.new(message)

      # Removing from function body all known structures, iterations and so no
      {contents, property_test} = parse_contents(contents, property_test)

      # extract the context vars in the remaining content
      context_vars = extract_context_vars(contents, property_test)

      # substitute the vars with the real value and register the test

      values = PropertyTest.get_values(property_test, context_vars)
      iterations_number = length(values)
      values
      |> Enum.reduce(1, fn iteration_values, num ->
        contents = Macro.postwalk(contents, fn
          v = {var_name, context, nil} ->
            Keyword.get(iteration_values, var_name, v)
          v -> v
        end)
        name = ExUnit.Case.register_test(__ENV__, :property, "#{message} - iteration #{num} of #{iterations_number}", [])
        def unquote(name)(_), do: unquote(contents)
        num + 1
      end)
    end
  end
end
