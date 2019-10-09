defmodule S12y.Parsers.Mix do
  alias S12y.Parsers.Mix.Parser

  @doc """
  Parse arbitrary mix.exs file and return the list of top-level dependencies defined in it.

  The file are expected to exist under `/tmp/[id]/mix.exs`.
  """
  def parse(id) do
    Parser.start(id)
  end
end
