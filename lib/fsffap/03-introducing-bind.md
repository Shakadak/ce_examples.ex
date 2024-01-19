Open a session with `iex -S mix`.  
You can then copy-paste the code, or write it yourself.  

```elixir
import ComputationExpression
import Fs.Option
import Fs.Map
```

[Series link](README.md)  
[Original article](https://fsharpforfunandprofit.com/posts/computation-expressions-bind/)

# Previous

2: [Computation expressions: Introduction](02-understanding-continuations.md) 
4: [Computation expressions and wrapper types](04-computation-expressions-and-wrapper-types.md)

# Introducing "Bind "

```elixir
# documentation
let! pattern = expr ; cexpr

# real example
let! x = 43 ; some expression
```

```elixir
# documentation
builder._Bind(expr, fn pattern -> cexpr end)

# real example
builder._Bind(43, fn x -> some expression end)
```

```elixir
let! x = 1
let! y = 2
let! z = x + y
```

```elixir
_Bind(1, fn x ->
_Bind(2, fn y ->
_Bind(x + y, fn z ->
# etc
end) end) end)
```

# A standalone bind function

```elixir
def m ~>> f, do: pipeInto(m, f)
```

```elixir
divideByWorkflow = fn x, y, w, z ->
  x |> divideBy.(y) ~>> (&divideBy.(&1, w)) ~>> &divideBy.(&1, z)
```

```elixir
def m ~>> f do
  :ok = IO.puts("expression is #{m}")
  f.(m)
end

loggingWorkflow = (
  1 ~>> (& &1 + 2) ~>> (& &1 * 42) ~>> &Function.identity/1
)
```

# Option.bind and the "maybe" workflow revisited

```elixir
pipeInto = fn m, f ->
  case m do
    none() -> none()
    some(x) -> x |> f.()
  end
end
```

```elixir
defmodule Fs.Option do
  import Fs.Option # Don't actually reload this module
  def bind(f, m) do
    case m do
      none() -> none()
      some(x) -> x |> f.()
    end
  end
end
```

```elixir
defmodule Maybe do
  import Fs.Option

  def _Bind(m, f), do: Fs.Option.bind(f, m)
  def _Pure(x), do: some(x)
end
```

# Reviewing the different approaches so far

```elixir
defmodule DivideByExplicit do
  import Fs.Option, only: [
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
```

```elixir
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
```

```elixir
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
```

```elixir
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
```

# Exercise: How well do you understand ?

## Part 1 = create a workflow

```elixir
strToInt = fn str -> ??? end
```

```elixir
stringAddWorkflow = fn x, y, z ->
  compute YourWorkflow do
    let! a = strToInt.(x)
    let! b = strToInt.(y)
    let! c = strToInt.(z)
    pure a + b + c
  end
end

# test
good = stringAddWorkflow.("12", "3", "2")
bad  = stringAddWorkflow.("12", "xyz", "2")
```

## Part 2 - create a bind function

```elixir
strAdd = fn str, i -> ??? end
defmodule Op do
  def m ~>> f, do: ???
end
import Op
```

```
good = strToInt.("1") ~>> (&strAdd.("2", &1)) ~>> &strAdd.("3", &1)
bad  = strToInt.("1") ~>> (&strAdd.("xyz", &1)) ~>> &strAdd.("3", &1)

# Next

2: [Computation expressions: Introduction](02-understanding-continuations.md) 
4: [Computation expressions and wrapper types](04-computation-expressions-and-wrapper-types.md)
