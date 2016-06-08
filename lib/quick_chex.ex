defmodule QuickChex do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import QuickChex.Generators
      ExUnit.plural_rule("property", "properties")
    end
  end

  defmacro property(message, vars, opts \\ :empty, do: contents) do
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
    setup_vars = Macro.escape(setup_vars)
    contents = Macro.escape(contents)
    quote bind_quoted: [opts: opts, message: message, contents: contents, setup_vars: setup_vars] do
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
end
