defmodule EvercamMedia.Mixfile do
  use Mix.Project

  def project do
    [app: :evercam_media,
     version: "1.0.0",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:make, :phoenix] ++ Mix.compilers,
     deps: deps]
  end

  defp aliases do
    [clean: ["clean", "clean.make"]]
  end

  def application do
    [mod: {EvercamMedia, []},
     applications: app_list(Mix.env)]
  end

  defp app_list(:dev), do: [:dotenv | app_list]
  defp app_list(_), do: app_list
  defp app_list, do: [
    :con_cache,
    :cowboy,
    :ecto,
    :erlcloud,
    :eredis,
    :exq,
    :httpotion,
    :runtime_tools,
    :tzdata,
    :httpoison,
    :inets,
    :phoenix,
    :porcelain,
    :postgrex,
    :calendar,
    :timex,
    :uuid,
    :xmerl
  ]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:phoenix, "~> 1.0.3"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:con_cache, "~> 0.6.0"},
     {:httpotion, github: "myfreeweb/httpotion"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.2", override: true},
     {:httpoison, "~> 0.7.2"},
     {:calendar, "~> 0.10.0"},
     {:dotenv, "~> 0.0.4"},
     {:poison, "~> 1.5"},
     {:timex, "~> 0.19", override: true},
     {:timex_ecto, "~> 0.5.0"},
     {:porcelain, "~> 2.0"},
     {:erlcloud, github: 'gleber/erlcloud'},
     {:exq, "~> 0.2.3"},
     {:uuid, github: 'zyro/elixir-uuid', override: true},
     {:exrm, "~> 0.14.16"}]
  end
end

defmodule Mix.Tasks.Compile.Make do
  @shortdoc "Compiles helper in c_src"

  def run(_) do
    {result, _error_code} = System.cmd("make", [], stderr_to_stdout: true)
    Mix.shell.info result

    :ok
  end
end

defmodule Mix.Tasks.Clean.Make do
  @shortdoc "Cleans helper in c_src"

  def run(_) do
    {result, _error_code} = System.cmd("make", ['clean'], stderr_to_stdout: true)
    Mix.shell.info result

    :ok
  end
end
