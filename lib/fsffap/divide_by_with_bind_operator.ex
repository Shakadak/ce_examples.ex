defmodule DivideByWithBindOperator do
  import Option, only: [
    some: 1,
    none: 0,
  ]

  def divideBy(top, bottom) do
    if bottom == 0 do
      none()
    else
      some(top / bottom)
    end
  end

  def m ~>> f, do: Option.bind(f, m)

  def divideByWorkflow(x, y, w, z) do
    x |> divideBy(y)
      ~>> (&divideBy(&1, w))
      ~>> &divideBy(&1, z)
  end

  def good, do: divideByWorkflow(12, 3, 2, 1) |> IO.inspect()
  def bad,  do: divideByWorkflow(12, 3, 0, 1) |> IO.inspect()
end
