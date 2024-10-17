defmodule Combinators do
  def identity(value), do: &{:ok, value, &1}

  defp bitchar(predicate, code, tail) do
    if predicate.(code) do
      {:ok, <<code>>, tail}
    else
      {:err, {:invalid_char, <<code>>, 1}}
    end
  end

  def char(predicate) do
    fn
      <<code, tail::bitstring>> -> bitchar(predicate, code, tail)
      "" -> {:err, {:unexpected_eof}}
      _ -> {:err, {:invalid_input}}
    end
  end

  def map(function, parser) do
    fn input ->
      case parser.(input) do
        {:ok, parsed, tail} -> {:ok, function.(parsed), tail}
        err -> err
      end
    end
  end

  def concat(function, parser, parser2) do
    fn input ->
      case parser.(input) do
        {:ok, head, tail} ->
          case parser2.(tail) do
            {:ok, head2, tail2} ->
              {:ok, function.(head, head2), tail2}

            {:err, {reason, char, pos}} ->
              {:err, {reason, char, String.length(input) - String.length(tail) + pos}}

            err ->
              err
          end

        err ->
          err
      end
    end
  end

  def either(parser, parser2) do
    fn input ->
      case parser.(input) do
        {:err, _} -> parser2.(input)
        ok -> ok
      end
    end
  end

  def any(parser) do
    fn input ->
      case parser.(input) do
        {:ok, parsed, tail} ->
          case any(parser).(tail) do
            {:ok, parsed2, tail2} -> {:ok, [parsed | parsed2], tail2}
            _ -> {:ok, [parsed], tail}
          end

        err ->
          err
      end
    end
  end

  def build(parser) do
    fn input ->
      case parser.(input) do
        {:ok, parsed, ""} -> parsed
        {:ok, _, tail} -> {:err, :expected_eof, tail}
        err -> err
      end
    end
  end

  def ignore(parser), do: map(fn _ -> :ignore end, parser)

  def sequence(parsers) do
    Enum.reduce(parsers, identity([]), fn parser, acc ->
      concat(
        fn parser, acc ->
          if parser == :ignore do
            acc
          else
            [parser | acc]
          end
        end,
        parser,
        acc
      )
    end)
  end

  def sequence(f, parsers), do: map(f, sequence(parsers))

  def nth(n, parsers), do: sequence(&Enum.at(&1, n), parsers)

  def choice([parser | parsers]), do: Enum.reduce(parsers, parser, &either/2)

  def optional(parser), do: either(parser, identity(nil))

  def many(parser), do: concat(&[&1 | &2], parser, any(parser))

  def str(parser), do: map(&Enum.join/1, parser)
end
