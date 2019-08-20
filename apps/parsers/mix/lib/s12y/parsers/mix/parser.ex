defmodule S12y.Parsers.Mix.Parser do
  def start(source) do
    initialize(source)
    |> generate_project!
    |> run
  end

  defp initialize(source), do: %{id: generate_id(), source: source}
  defp generate_id(), do: UUID.uuid4()

  defp generate_project!(parser) do
    parser
    |> create_directory!
    |> copy_parser_script!
    |> write_mix_exs!
  end

  defp run(parser) do
    {out, 0} = System.cmd("elixir", [script()], cd: directory(parser))
    out
  end

  defp create_directory!(parser) do
    parser
    |> directory
    |> File.mkdir_p!()

    parser
  end

  defp copy_parser_script!(parser) do
    File.copy!(parser_template(), script_destination(parser))
    parser
  end

  defp write_mix_exs!(parser) do
    File.write!(mix_exs_destination(parser), parser.source)
    parser
  end

  defp app_name, do: Mix.Project.config()[:app]
  defp directory(parser), do: Path.join("/tmp", parser.id)
  defp mix_exs, do: "mix.exs"
  defp mix_exs_destination(parser), do: Path.join(directory(parser), mix_exs())
  defp parser_template, do: Path.join([:code.priv_dir(app_name()), "templates", "parser.exs"])
  defp script, do: "parser.exs"
  defp script_destination(parser), do: Path.join(directory(parser), script())
end
