defmodule TZ48.Util do
  @doc """
  Transposes a nested list.

  Converts the rows into columms of a nested list.
    iex> list = [[1, 2, 3], [4, 5, 6]]
    iex> Util.transpose(list)
    [[1, 4], [2, 5], [3, 6]]
  """
  def transpose([[] | _]), do: []

  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end
end
