defmodule DivideByWithCompExpr do
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

  def divideByWorkflow(x, y, w, z) do
    import ComputationExpression
    compute MaybeBuilder do
      let! a = x |> divideBy(y)
      let! b = a |> divideBy(w)
      let! c = b |> divideBy(z)
      pure(c)
    end
  end

  def good, do: divideByWorkflow(12, 3, 2, 1) |> IO.inspect()
  def bad,  do: divideByWorkflow(12, 3, 0, 1) |> IO.inspect()
end
