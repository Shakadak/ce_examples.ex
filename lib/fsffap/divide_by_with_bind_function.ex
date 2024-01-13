defmodule DivideByWithBindFunction do
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

  def bind(m, f), do: Option.bind(f, m)

  def pure(x), do: some(x)

  def divideByWorkflow(x, y, w, z) do
    bind(x |> divideBy(y), fn a ->
    bind(a |> divideBy(w), fn b ->
    bind(b |> divideBy(z), fn c ->
    pure(c)
    end) end) end)
  end

  def good, do: divideByWorkflow(12, 3, 2, 1) |> IO.inspect()
  def bad,  do: divideByWorkflow(12, 3, 0, 1) |> IO.inspect()
end
