defmodule DivideByExplicit do
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
    a = x |> divideBy(y)
    case a do
      none() -> none() # give up
      some(a1) ->      # keep going
        b = a1 |> divideBy(w)
        case b do
          none() -> none() # give up
          some(b1) ->      # keep going
            c = b1 |> divideBy(z)
            case c do
              none() -> none() # give up
              some(c1) ->      # keep going
                # return
                some(c1)
            end
        end
    end
  end

  def good, do: divideByWorkflow(12, 3, 2, 1) |> IO.inspect()
  def bad,  do: divideByWorkflow(12, 3, 0, 1) |> IO.inspect()
end
