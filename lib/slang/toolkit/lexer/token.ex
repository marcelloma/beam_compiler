defmodule Slang.Toolkit.Lexer.Token do
  alias Slang.Toolkit.Lexer.{State, Token, TokenDef}

  @type t() :: %Token{
          name: TokenDef.name(),
          code: State.code(),
          text: State.code(),
          skip: TokenDef.skip(),
          line: State.line_number(),
          column: State.line_column()
        }

  defstruct [:name, :code, :text, :skip, :line, :column]

  @spec new(State.t(), TokenDef.t(), State.code()) :: Token.t()
  def new(state, token_def, code) do
    %Token{
      name: token_def.name,
      code: code,
      text: token_def.format.(code),
      skip: token_def.skip,
      line: state.current_line,
      column: state.current_column
    }
  end
end
