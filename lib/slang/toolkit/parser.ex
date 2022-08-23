defmodule Slang.Toolkit.Parser do
  alias Slang.Toolkit.Lexer.Token

  def extract_meta(%Token{line: line, column: column}), do: :erl_anno.new({line, column})

  def match([%Token{name: name} | _tokens], name), do: true
  def match(_tokens, _name), do: false

  def match_next([_token | tokens], name), do: match(tokens, name)

  def match!(tokens, name) do
    true = match(tokens, name)
    consume(tokens)
  end

  def consume([token | tokens]), do: {token, tokens}
end
