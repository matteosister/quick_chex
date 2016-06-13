defmodule QuickChex.Mixfile do
  use Mix.Project

  def project do
    [app: :quick_chex,
     version: "0.2.0",
     elixir: "~> 1.3-rc",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  defp description do
    "property based testing for elixir"
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev},
    {:earmark, ">= 0.0.0", only: :dev},
    {:credo, "~> 0.4", only: [:dev, :test]}]
  end

  defp package do
    [
      maintainers: ["Matteo Giachino"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/matteosister/quick_chex"}
    ]
  end
end
