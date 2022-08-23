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

  def compile_structure() do
    Compiler.compile(@structure)

    apply(:company_1000, :payout_rule_1, [%{}]) |> IO.inspect(label: "company_1000.payout_rule_1")
    apply(:company_1000, :payout_rule_2, [%{}]) |> IO.inspect(label: "company_1000.payout_rule_2")

    apply(:company_1000, :payout_rule_3, [%{connector_field_Amount: Decimal.new("30000")}])
    |> IO.inspect(label: "company_1000.payout_rule_3")

    :ok
  end

  def lex_and_parse(code) do
    code
    |> Lexer.lex()
    |> Parser.parse()
  end
end
