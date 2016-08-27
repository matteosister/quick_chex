# QuickChex

[![Build Status](https://semaphoreci.com/api/v1/matteosister/quick_chex/branches/master/badge.svg)](https://semaphoreci.com/matteosister/quick_chex)

This is an elixir library to do property based testing.

Please report any bugs or ideas you may have...this is a work in progress, not
sure if this is gonna really happen.

It needs elixir 1.3.0

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `quick_chex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:quick_chex, "~> 0.4"}]
    end
    ```

  2. Ensure `quick_chex` is started before your application:

    ```elixir
    def application do
      [applications: [:quick_chex]]
    end
    ```
