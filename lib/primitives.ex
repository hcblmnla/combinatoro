import Combinators

defmodule Primitives do
  def chars(string), do: string |> Chars.in_string?() |> char()

  def space(), do: char(&Chars.is_whitespace?/1)

  def ws(), do: space() |> any() |> ignore()

  def digit(), do: char(&Chars.is_digit?/1)

  def digits(), do: digit() |> many()

  def number(), do: map(&Chars.parse_integer/1, digits() |> str())

  def integer() do
    map(
      &Chars.parse_integer/1,
      sequence([
        optional(chars("+-")),
        digits()
      ])
      |> str()
    )
  end
end
