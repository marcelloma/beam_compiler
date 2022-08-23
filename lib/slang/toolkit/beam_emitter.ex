defmodule Slang.Toolkit.BeamEmitter do
  def emit_module(name), do: emit_attribute(:module, name)

  def emit_export(functions), do: emit_attribute(:export, functions)

  def emit_inline(), do: emit_attribute(:compile, :inline)

  def emit_nil(), do: {nil, line_1()}

  def emit_atom(atom, anno), do: {:atom, anno, atom}

  def emit_nil(anno), do: {nil, anno}

  def emit_var(name), do: {:var, line_1(), name}

  def emit_var(name, anno), do: {:var, anno, name}

  def emit_map(map) do
    map_properties =
      map
      |> Enum.map(fn {k, v} -> {:map_field_assoc, line_1(), {:atom, line_1(), k}, v} end)

    {:map, line_1(), map_properties}
  end

  def emit_list([]) do
    emit_nil()
  end

  def emit_list([head|list]) do
    [:cons, line_1(), head, emit_list(list)] |> List.to_tuple()
  end

  def emit_function(name, body),
    do: {:function, line_1(), name, 0, [{:clause, line_1(), [], [], [body]}]}

  def emit_lambda(body, args),
    do: {:fun, line_1(), {:clauses, [{:clause, line_1(), args, [], [body]}]}}

  def emit_decimal_new(value, anno),
    do: emit_external_call(:"Elixir.Decimal", :new, [{:string, anno, value}], anno)

  def emit_decimal_add(left_value, right_value, anno),
    do: emit_external_call(:"Elixir.Decimal", :add, [left_value, right_value], anno)

  def emit_decimal_subtract(left_value, right_value, anno),
    do: emit_external_call(:"Elixir.Decimal", :sub, [left_value, right_value], anno)

  def emit_decimal_multiply(left_value, right_value, anno),
    do: emit_external_call(:"Elixir.Decimal", :mult, [left_value, right_value], anno)

  def emit_decimal_divide(left_value, right_value, anno),
    do: emit_external_call(:"Elixir.Decimal", :div, [left_value, right_value], anno)

  def emit_call(function, args, anno),
    do: {:call, anno, {:atom, anno, function}, args}

  defp emit_external_call(module, function, args, anno),
    do: {:call, anno, {:remote, anno, {:atom, anno, module}, {:atom, anno, function}}, args}

  defp emit_attribute(key, value), do: {:attribute, line_1(), key, value}

  defp line_1(), do: :erl_anno.new(1)
end
