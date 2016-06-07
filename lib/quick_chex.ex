defmodule QuickChex do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      ExUnit.plural_rule("property", "properties")
      #Module.register_attribute __MODULE__, :generators, accumulate: true
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
    contents = Macro.escape(contents)

    quote bind_quoted: binding do
      name = ExUnit.Case.register_test(__ENV__, :property, message, [])
      def unquote(name)(unquote(var)) do
        unquote(contents)
      end
    end
  end

  defmacro prop(message, opts \\ [], do: contents) do
    contents = Macro.escape(contents)
    opts = Macro.escape(opts)

    quote bind_quoted: [opts: opts, message: message, contents: contents] do
      iterations = opts[:iterations]
      Enum.map 0..iterations, fn num ->
        name = ExUnit.Case.register_test(__ENV__, :property, message <> to_string(num), [])
        def unquote(name)(_) do
          args = unquote(opts)[:generators]
          |> Enum.map(fn {name, gen} -> {name, gen.()} end)
          IO.inspect args
          #Code.eval_quoted(unquote(contents), args)
        end
      end
    end
  end

  def int do
    fn ->
      1..100
      |> Enum.random
    end
  end
end
