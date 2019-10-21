defmodule S12y.Parsers.Mix.Parser do
  def start(id) do
    initialize(id)
    |> generate_project!
    |> run
  end

  defp initialize(id), do: %{id: id, path: "/tmp/#{id}"}

  defp generate_project!(parser) do
    parser
    |> copy_parser_script!
  end

  defp run(parser) do
    case System.cmd("elixir", [script()], cd: parser.path, stderr_to_stdout: true) do
      {output, 0} ->
        {:ok, output}

      error ->
        {:error, error}
    end
  end

  defp copy_parser_script!(parser) do
    File.copy!(parser_template(), script_destination(parser))
    parser
  end

  defp app_name, do: Mix.Project.config()[:app]
  defp parser_template, do: Path.join([:code.priv_dir(app_name()), "templates", "parser.exs"])
  defp script, do: "parser.exs"
  defp script_destination(parser), do: Path.join(parser.path, script())
end
