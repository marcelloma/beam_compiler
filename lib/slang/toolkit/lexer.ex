defmodule Slang.Toolkit.Lexer do
  alias Slang.Toolkit.Lexer.{State, Token, TokenDef}

  @type t() :: [Token.t()]

  @newline_regex "(\\r\\n|\\r|\\n)"
  @whitespace_regex "\\s+"

  @spec lex(State.code(), State.token_defs()) :: t()
  def lex(code, token_defs) do
    newline_token = TokenDef.new(:newline, @newline_regex, skip: true)
    whitespace_token = TokenDef.new(:whitespace, @whitespace_regex, skip: true)
    token_defs = [whitespace_token, newline_token] ++ token_defs
    lex(%State{code: code, token_defs: token_defs})
  end

  @spec lex(State.t()) :: t()
  def lex(%State{code: ""}), do: []

  def lex(%State{token_defs: token_defs} = state) do
    case Enum.find_value(token_defs, &TokenDef.match(state, &1)) do
      nil ->
        raise "bad token"

      %Token{skip: true} = token ->
        state |> consume_token(token) |> lex()

      %Token{} = token ->
        state = state |> consume_token(token) |> lex()
        [token | state]
    end
  end

  @spec consume_token(State.t(), Token.t()) :: State.t()
  defp consume_token(state, token) do
    token_code_length = String.length(token.code)

    new_line_count =
      ~r/#{@newline_regex}/
      |> Regex.scan(token.code)
      |> Enum.count()

    update_current_column =
      &if new_line_count == 0,
        do: &1 + token_code_length,
        else: 0

    update_current_line = &(&1 + new_line_count)

    state
    |> Map.update!(:code, &String.slice(&1, token_code_length..-1))
    |> Map.update!(:current_line, update_current_line)
    |> Map.update!(:current_column, update_current_column)
  end
end
