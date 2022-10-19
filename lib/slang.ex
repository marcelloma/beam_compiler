defmodule Slang do
  alias Slang.{Compiler, Lexer, Parser}

  @structure %{
    company_id: 1000,
    payout_rules: [
      %{
        id: 1,
        formula: "1+1"
      },
      %{
        id: 2,
        formula: "10*100"
      },
      %{
        id: 3,
        formula: "marginal_payout(connector_field_Amount, range_table_AcceleratorTable())"
      },
      %{
        id: 4,
        formula: "sum([#{Enum.join(1..1000, ",")}])"
      }
    ],
    range_tables: [
      %{
        id: "AcceleratorTable",
        rows: [
          %{
            upper_bound: "1000",
            return_value: "Allocation * 0.05"
          },
          %{
            lower_bound: "1000",
            upper_bound: "2000",
            return_value: "Allocation * 0.075"
          },
          %{
            lower_bound: "2000",
            upper_bound: "3000",
            return_value: "Allocation * 0.08"
          },
          %{
            lower_bound: "3000",
            return_value: "Allocation * 0.085"
          }
        ]
      }
    ]
  }

  def measured(name, times \\ 1000, fun) do
    {usec, _} =
      :timer.tc(fn ->
        Enum.each(1..times, fn _ ->
          fun.()
        end)
      end)

    IO.puts("#{times}x #{name}: #{usec / 1000}ms")
  end

  def compile_structure() do
    Compiler.compile(@structure)

    args = [%{}]
    measured("Payout Rule 1", fn -> apply(:company_1000, :payout_rule_1, args) end)
    measured("Payout Rule 2", fn -> apply(:company_1000, :payout_rule_2, args) end)

    args = [%{connector_field_Amount: Decimal.new("30000")}]
    measured("Payout Rule 3", fn -> apply(:company_1000, :payout_rule_3, args) end)

    args = [%{}]
    measured("Payout Rule 4", fn -> apply(:company_1000, :payout_rule_4, args) end)

    :ok
  end

  def lex_and_parse(code) do
    code
    |> Lexer.lex()
    |> Parser.parse()
  end
end
