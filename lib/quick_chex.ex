defmodule QuickChex do
  alias QuickChex.PropertyTest

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators

      ExUnit.plural_rule("property", "properties")
    end
  end

  defmacro property_old(message, vars, opts \\ :empty, do: contents) do
    setup_vars = if opts === :empty do
      nil
    else
      vars
    end
    opts = if opts === :empty do
      vars
    else
      opts
    end
    contents = Macro.escape(contents)
    setup_vars = Macro.escape(setup_vars)
    quote bind_quoted: [message: message, opts: opts, contents: contents, setup_vars: setup_vars] do
      iterations = opts[:iterations] || 10
      generators = opts[:generators]
      Enum.map 1..iterations, fn num ->
        name = ExUnit.Case.register_test(__ENV__, :property, message <> to_string(num), [])
        contents = Macro.postwalk(contents, fn
          v = {var, context, nil} ->
            if var in Keyword.keys(generators) do
              Keyword.get(generators, var).()
            else
              v
            end
          other -> other
        end)
        if is_nil(setup_vars) do
          def unquote(name)(_) do
            unquote(contents)
          end
        else
          def unquote(name)(unquote(setup_vars)) do
            unquote(contents)
          end
        end
      end
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
end
