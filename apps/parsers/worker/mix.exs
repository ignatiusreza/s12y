defmodule S12y.Parsers.Worker.MixProject do
  use Mix.Project

  def project do
    [
      app: :s12y_parsers_worker,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {S12y.Parsers.Worker.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:s12y_cli, path: Path.expand("../../cli", __DIR__)},
      {:s12y, path: Path.expand("../../s12y", __DIR__)}
    ]
  end
end
