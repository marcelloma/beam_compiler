defmodule Slang.Compiler do
  import Slang.BeamEmitter
  import Slang.Toolkit.BeamEmitter

  def compile(structure) do
    module_name = :"company_#{structure.company_id}"

    payout_rule_functions = prepare_payout_rules(structure)

    payout_rule_function_exports =
      payout_rule_functions
      |> Enum.map(&{&1.name, 0})
      |> emit_export()

    emitted_payout_rules = Enum.map(payout_rule_functions, &emit_slang_payout_rule/1)

    range_table_functions = prepare_range_tables(structure)

    emitted_range_tables = Enum.map(range_table_functions, &emit_slang_range_table/1)

    emitted_builtins = emit_slang_builtins()

    {:ok, ^module_name, binary} =
      [
        emit_module(module_name),
        emit_inline(),
        payout_rule_function_exports,
      ]
      |> Kernel.++(emitted_payout_rules)
      |> Kernel.++(emitted_range_tables)
      |> Kernel.++(emitted_builtins)
      |> :compile.forms()

    {:module, ^module_name} = :code.load_binary(module_name, 'company_structure', binary)

    :ok
  end

  defp prepare_payout_rules(structure) do
    structure.payout_rules
    |> Stream.map(&Map.put(&1, :name, :"payout_rule_#{&1.id}"))
    |> Stream.map(&Map.put(&1, :ast, Slang.lex_and_parse(&1.formula)))
  end

  defp prepare_range_tables(structure) do
    Enum.map(structure.range_tables, fn range_table ->
      range_table
      |> Map.put(:name, :"range_table_#{range_table.id}")
      |> Map.update!(:rows, & prepare_range_table_rows/1)
    end)
  end

  defp prepare_range_table_rows(rows) do
    lex_and_parse = fn map, key ->
      if Map.has_key?(map, key),
        do: map |> Map.get(key) |> Slang.lex_and_parse(),
        else: "nil" |> Slang.lex_and_parse()
    end

    Enum.map(rows, fn row ->
      row
      |> Map.put(:lower_bound, lex_and_parse.(row, :lower_bound))
      |> Map.put(:upper_bound, lex_and_parse.(row, :upper_bound))
      |> Map.put(:return_value, lex_and_parse.(row, :return_value))
    end)
  end
end
