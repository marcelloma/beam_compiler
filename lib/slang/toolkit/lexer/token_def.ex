defmodule Slang.Toolkit.Lexer.TokenDef do
  alias Slang.Toolkit.Lexer.{State, Token, TokenDef}

  @type name() :: atom()
  @type regex() :: Regex.t()
  @type skip() :: boolean()
  @type format() :: (State.code() -> State.code())

  @type t() :: %TokenDef{
          name: name(),
          regex: regex(),
          skip: skip(),
          format: format
        }

  defstruct [:name, :regex, :skip, :format]

  @spec match(State.t(), TokenDef.t()) :: Token.t() | nil
  def match(state, token_def) do
    case Regex.run(token_def.regex, state.code) do
      [text] -> Token.new(state, token_def, text)
      nil -> nil
    end
  end

  def new(name, regex_str, opts \\ []) do
    skip = Keyword.get(opts, :skip, false)
    format = Keyword.get(opts, :format, & &1)

    %TokenDef{
      name: name,
      regex: ~r/^#{regex_str}/,
      skip: skip,
      format: format
    }
  end
end
