defmodule Slang.Lexer do
  alias Slang.Toolkit
  alias Slang.Toolkit.Lexer.{Token, TokenDef}

  @spec lex(Toolkit.Lexer.code()) :: [Token.t()]
  def lex(code), do: Toolkit.Lexer.lex(code, token_defs())

  defp token_defs() do
    [
      TokenDef.new(nil, "nil"),
      TokenDef.new(:if, "if"),
      TokenDef.new(:else, "else"),
      TokenDef.new(:boolean, "(true|false)"),
      TokenDef.new(:string, "\".*?\"", format: &String.trim(&1, "\"")),
      TokenDef.new(:identifier, "[A-Za-z][A-Za-z0-9_]*"),
      TokenDef.new(:less, "<"),
      TokenDef.new(:less_equal, "<="),
      TokenDef.new(:greater, ">"),
      TokenDef.new(:greater_equal, ">="),
      TokenDef.new(:arrow, "->"),
      TokenDef.new(:and, "&&"),
      TokenDef.new(:or, "\\|\\|"),
      TokenDef.new(:cross, "\\+"),
      TokenDef.new(:dash, "-"),
      TokenDef.new(:star, "\\*"),
      TokenDef.new(:slash, "/"),
      TokenDef.new(:caret, "\\^"),
      TokenDef.new(:percent, "%"),
      TokenDef.new(:comma, ","),
      TokenDef.new(:equal, "=="),
      TokenDef.new(:not_equal, "!="),
      TokenDef.new(:bang, "!"),
      TokenDef.new(:assign, "="),
      TokenDef.new(:left_paren, "\\("),
      TokenDef.new(:right_paren, "\\)"),
      TokenDef.new(:left_brace, "{"),
      TokenDef.new(:right_brace, "}"),
      TokenDef.new(:left_bracket, "\\["),
      TokenDef.new(:right_bracket, "\\]"),
      TokenDef.new(:number, "\\d+\\.\\d+|\\d+"),
      TokenDef.new(:period, "\\.")
    ]
  end
end
