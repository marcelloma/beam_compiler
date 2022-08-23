defmodule Slang.Toolkit.Lexer.State do
  alias Slang.Toolkit.Lexer.State
  alias Slang.Toolkit.Lexer.TokenDef

  @type code() :: String.t()
  @type token_defs() :: [TokenDef.t()]
  @type line() :: non_neg_integer()
  @type column() :: non_neg_integer()

  @type t() :: %State{
          code: code(),
          token_defs: token_defs(),
          current_line: line(),
          current_column: column()
        }

  defstruct [:code, :token_defs, current_line: 1, current_column: 1]
end
