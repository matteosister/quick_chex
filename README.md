# QuickChex

This is a elixir library to do property based testing.

Please report any bugs or ideas you may have...this is a work in progress, not
sure if this is gonna really happen.

It needs elixir 1.3.0

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `quick_chex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:quick_chex, "~> 0.3"}]
    end
    ```

  2. Ensure `quick_chex` is started before your application:

    ```elixir
    def application do
      [applications: [:quick_chex]]
    end
    ```
