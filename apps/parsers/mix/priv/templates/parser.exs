defmodule Parser do
  def start_mix do
    Mix.start()
    Mix.Local.append_archives()
    Mix.Local.append_paths()
    Code.compile_file(mix_file())
  end

  def dep_json do
    []
    |> Mix.Dep.load_on_environment()
    |> to_json
  end

  defp mix_file, do: Path.join(__DIR__, "mix.exs")

  defp to_json(deps) do
    entries =
      deps
      |> Enum.map(fn dep ->
        String.trim("""
          "#{dep.app}": { "repo": "#{dep.opts[:repo]}", "version": "#{dep.requirement}"}
        """)
      end)
      |> Enum.join(",")

    "{#{entries}}"
  end
end

Parser.start_mix()
IO.puts(Parser.dep_json())
