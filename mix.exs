defmodule TokenBucket.MixProject do
  use Mix.Project

  def project do
    [
      app: :tokenbucket,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "TokenBucket",
      source_url: "https://github.com/blankenshipz/tokenbucket"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mutex, "~> 1.3"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A token bucket implementation for simple rate limiting"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "tokenbucket",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/blankenshipz/tokenbucket"}
    ]
  end
end
