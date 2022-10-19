defmodule Slang.Parser do
  import Slang.Toolkit.Parser

  def parse(tokens) do
    {ast, []} = expression(tokens)
    ast
  end

  defp expression(tokens) do
    debug(tokens, "expression")

    term(tokens)
  end

  defp term(tokens) do
    debug(tokens, "term")

    {left_operand, tokens} = multiplication(tokens)

    cond do
      match(tokens, :cross) ->
        {token, tokens} = consume(tokens)
        {right_operand, tokens} = term(tokens)
        {[:+, left_operand, right_operand, extract_meta(token)], tokens}

      match(tokens, :dash) ->
        {token, tokens} = consume(tokens)
        {right_operand, tokens} = term(tokens)
        {[:-, left_operand, right_operand, extract_meta(token)], tokens}

      true ->
        {left_operand, tokens}
    end
  end

  defp multiplication(tokens) do
    debug(tokens, "multiplication")

    {left_operand, tokens} = division(tokens)

    cond do
      match(tokens, :star) ->
        {token, tokens} = consume(tokens)
        {right_operand, tokens} = multiplication(tokens)
        {[:*, left_operand, right_operand, extract_meta(token)], tokens}

      true ->
        {left_operand, tokens}
    end
  end

  defp division(tokens) do
    debug(tokens, "division")

    {left_operand, tokens} = unary(tokens)

    cond do
      match(tokens, :slash) ->
        {token, tokens} = consume(tokens)
        {right_operand, tokens} = division(tokens)
        {[:/, left_operand, right_operand, extract_meta(token)], tokens}

      true ->
        {left_operand, tokens}
    end
  end

  defp unary(tokens) do
    debug(tokens, "unary")

    cond do
      match(tokens, :dash) ->
        {token, tokens} = consume(tokens)
        {operand, tokens} = unary(tokens)
        {[:-, operand, extract_meta(token)], tokens}

      true ->
        function_call(tokens)
    end
  end

  defp function_call(tokens) do
    debug(tokens, "function_call")

    cond do
      match(tokens, :identifier) and match_next(tokens, :left_paren) ->
        {identifier_token, tokens} = consume(tokens)
        {_token, tokens} = match!(tokens, :left_paren)
        {args, tokens} = function_args(tokens)
        function_name = String.to_atom(identifier_token.text)
        {[:fn_call, function_name, args, extract_meta(identifier_token)], tokens}

      true ->
        primary(tokens)
    end
  end

  defp function_args(tokens, args \\ []) do
    debug(tokens, "function_args")

    cond do
      match(tokens, :right_paren) ->
        {_token, tokens} = consume(tokens)
        {args, tokens}

      match(tokens, :comma) ->
        {_token, tokens} = consume(tokens)
        function_args(tokens, args)

      true ->
        {expression, tokens} = expression(tokens)
        function_args(tokens, args ++ [expression])
    end
  end

  defp list_items(tokens, items \\ []) do
    debug(tokens, "list_items")

    cond do
      match(tokens, :right_bracket) ->
        {_token, tokens} = consume(tokens)
        {items, tokens}

      match(tokens, :comma) ->
        {_token, tokens} = consume(tokens)
        list_items(tokens, items)

      true ->
        {expression, tokens} = expression(tokens)
        list_items(tokens, items ++ [expression])
    end
  end

  defp primary(tokens) do
    debug(tokens, "primary")

    cond do
      match(tokens, :number) ->
        {token, tokens} = consume(tokens)
        {[:number, token.text, extract_meta(token)], tokens}

      match(tokens, nil) ->
        {token, tokens} = consume(tokens)
        {[nil, extract_meta(token)], tokens}

      match(tokens, :identifier) ->
        {token, tokens} = consume(tokens)
        {[:identifier, String.to_atom(token.text), extract_meta(token)], tokens}

      match(tokens, :left_paren) ->
        {_token, tokens} = consume(tokens)
        {expression, tokens} = expression(tokens)
        {_token, tokens} = match!(tokens, :right_paren)
        {expression, tokens}

      match(tokens, :left_bracket) ->
        {token, tokens} = consume(tokens)
        {items, tokens} = list_items(tokens)
        {[:list, items, extract_meta(token)], tokens}
    end
  end

  defp debug(tokens, label) do
    if false do
      tokens |> Enum.map(& &1.text) |> IO.inspect(label: label)
    end
  end
end
