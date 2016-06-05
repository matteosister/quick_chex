defmodule QuickChex do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      ExUnit.plural_rule("property", "properties")
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

    quote bind_quoted: binding do
      Enum.each 1..10, fn num ->
        name = ExUnit.Case.register_test(__ENV__, :property, message <> to_string(num), [])
        def unquote(name)(unquote(var)), do: unquote(contents)
      end
    end
  end
end
