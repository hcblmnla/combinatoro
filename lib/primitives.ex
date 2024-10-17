import Combinators

defmodule Primitives do
  def space(), do: char(&Chars.is_whitespace/1)

  def ws(), do: space() |> any() |> ignore()

  def digit(), do: char(&Chars.is_digit/1)

  def digits(), do: digit() |> many()
end
