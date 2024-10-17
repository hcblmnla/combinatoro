defmodule Chars do
  def is_whitespace(code) when is_integer(code), do: code in [?\s, ?\t, ?\n, ?\r, ?\v]

  def is_letter(code) when is_integer(code), do: code in ?a..?z or code in ?A..?Z

  def is_digit(code) when is_integer(code), do: code in ?0..?9
end
