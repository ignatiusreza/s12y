defmodule S12y.Parsers.Mix do
  alias S12y.Parsers.Mix.Parser

  @doc """
  Parse arbitrary mix.exs string input and return the list of top-level dependencies defined in it.
  """
  def parse(source) do
    Parser.start(source)
  end
end
