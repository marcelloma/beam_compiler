defmodule Slang.BeamEmitter do
  import Slang.Toolkit.BeamEmitter

  def emit_slang_payout_rule(%{name: name, ast: ast}) do
    env_var = emit_var(:Env)
    emit_function(name, [env_var], emit_slang_ast(ast))
  end

  def emit_slang_range_table(%{name: name, rows: rows}) do
    rows = Enum.map(rows, &emit_slang_range_table_row/1)
    emit_function(name, [], emit_list(rows))
  end

  def emit_slang_range_table_row(row) do
    allocation_var = emit_var(:Allocation)
    lower_bound = emit_slang_ast(row.lower_bound)
    upper_bound = emit_slang_ast(row.upper_bound)
    return_value = row.return_value |> emit_slang_ast() |> emit_lambda([allocation_var])

    %{lower_bound: lower_bound, upper_bound: upper_bound, return_value: return_value}
    |> emit_map()
  end

  def emit_slang_ast([nil, anno]), do: emit_atom(nil, anno)

  def emit_slang_ast([:number, number, anno]), do: emit_decimal_new(number, anno)

  def emit_slang_ast([:identifier, :Allocation, anno]) do
    emit_var(:Allocation, anno)
  end

  def emit_slang_ast([:identifier, name, anno]) do
    env_var = emit_var(:Env, anno)

    emit_external_call(:maps, :get, [{:atom, anno, name}, env_var], anno)
  end

  def emit_slang_ast([:+, left_operand_ast, right_operand_ast, anno]) do
    left_operand = emit_slang_ast(left_operand_ast)
    right_operand = emit_slang_ast(right_operand_ast)
    emit_decimal_add(left_operand, right_operand, anno)
  end

  def emit_slang_ast([:-, left_operand_ast, right_operand_ast, anno]) do
    left_operand = emit_slang_ast(left_operand_ast)
    right_operand = emit_slang_ast(right_operand_ast)
    emit_decimal_subtract(left_operand, right_operand, anno)
  end

  def emit_slang_ast([:*, left_operand_ast, right_operand_ast, anno]) do
    left_operand = emit_slang_ast(left_operand_ast)
    right_operand = emit_slang_ast(right_operand_ast)
    emit_decimal_multiply(left_operand, right_operand, anno)
  end

  def emit_slang_ast([:/, left_operand_ast, right_operand_ast, anno]) do
    left_operand = emit_slang_ast(left_operand_ast)
    right_operand = emit_slang_ast(right_operand_ast)
    emit_decimal_divide(left_operand, right_operand, anno)
  end

  def emit_slang_ast([:list, item_asts, _anno]) do
    item_asts
    |> Enum.map(&emit_slang_ast(&1))
    |> emit_list()
  end

  def emit_slang_ast([:fn_call, name, [], anno]) do
    emit_call(name, [], anno)
  end

  def emit_slang_ast([:fn_call, :marginal_payout, [amount_ast, range_table_ast], anno]) do
    amount = emit_slang_ast(amount_ast)
    range_table = emit_slang_ast(range_table_ast)
    emit_call(:marginal_payout, [amount, range_table], anno)
  end

  def emit_slang_ast([:fn_call, :sum, [list_ast], anno]) do
    emit_call(:sum, [emit_slang_ast(list_ast)], anno)
  end

  def emit_slang_builtins() do
    [emit_slang_marginal_payout(), emit_slang_sum()]
  end

  def emit_slang_marginal_payout() do
    '''
    marginal_payout(Amount, RangeTable) ->
      Reducer = fun(Row, {Value, Payout}) ->
        LowerBound = maps:get(lower_bound, Row),
        UpperBound = maps:get(upper_bound, Row),
        ReturnValue = maps:get(return_value, Row),
        Allocation =
          if
            LowerBound =:= nil andalso UpperBound =:= nil -> Value;
            LowerBound =:= nil -> 'Elixir.Decimal':min(UpperBound, Value);
            UpperBound =:= nil -> 'Elixir.Decimal':max('Elixir.Decimal':sub(Value, LowerBound), 'Elixir.Decimal':new(0));
            true -> 'Elixir.Decimal':max('Elixir.Decimal':sub('Elixir.Decimal':min(UpperBound, Value), LowerBound), 'Elixir.Decimal':new(0))
          end,
        % io:format("~f -> ~f ~n", ['Elixir.Decimal':to_float(Allocation), 'Elixir.Decimal':to_float(ReturnValue(Allocation))]),
        {Value, 'Elixir.Decimal':add(Payout, ReturnValue(Allocation))}
      end,
      lists:foldl(Reducer, {Amount, 'Elixir.Decimal':new(0)}, RangeTable).
    '''
    |> :erl_scan.string()
    |> elem(1)
    |> :erl_parse.parse()
    |> elem(1)
  end

  def emit_slang_sum() do
    '''
    sum(List) ->
      Reducer = fun(Value, Acc) ->
        'Elixir.Decimal':add(Value, Acc)
      end,
      lists:foldl(Reducer, 'Elixir.Decimal':new(0), List).
    '''
    |> :erl_scan.string()
    |> elem(1)
    |> :erl_parse.parse()
    |> elem(1)
  end

  def emit_slang_help() do
    '''
    help(Env) ->
      maps:get(test, Env).
    '''
    |> :erl_scan.string()
    |> elem(1)
    |> :erl_parse.parse()
    |> elem(1)
  end
end
