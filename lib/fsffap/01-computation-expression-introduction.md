Open a session with `iex -S mix`.  
You can then copy-paste the code, or write it yourself.

```elixir
import ComputationExpression
import Fs.Option
import Fs.Map
```

[Series link](README.md)  
[Original article](https://fsharpforfunandprofit.com/posts/computation-expressions-intro/)

# Next

2. [Understanding continuations](02-understanding-continuations.md)

# Background

```elixir
let! pattern = expr ; cexpr
```

```elixir
builder._Bind(expr, fn pattern -> cexpr end)
```
# Computation expressions in practice

```elixir
log = fn p -> IO.puts("expression is #{inspect(p)}") ; {} end

loggedWorkflow = (
  x = 42
  log.(x)
  y = 43
  log.(y)
  z = x + y
  log.(z)
  # return
  z
)
```

```elixir
defmodule Logging do
  def log(p) do
    :ok = IO.puts("expression is #{inspect(p)}")
    {} # F#'s `printfn` is supposed to return unit
  end

  def _Bind(x, f) do
    log(x)
    f.(x)
  end

  def _Pure(x), do: x
end
```

```elixir
loggedWorkflow = compute Logging do
  let! x = 42
  let! y = 43
  let! z = x + y
  pure z
end
```

# Safe Division

```elixir
divideBy = fn top, bottom ->
  if bottom == 0 do
    none()
  else
    some(top / bottom)
  end
end
```

```elixir
divideByWorkflow = fn init, x, y, z ->
  a = init |> divideBy.(x)
  case a do
    none() -> none() # give up
    some(a1) ->      # keep going
      b = a1 |> divideBy.(y)
      case b do
        none() -> none() # give up
        some(b1) ->      # keep going
          c = b1 |> divideBy.(z)
          case c do
            none() -> none() # give up
            some(c1) ->      # keep going
              # return
              some(c1)
          end
      end
  end
end
```

```elixir
good = divideByWorkflow.(12, 3, 2, 1)
bad  = divideByWorkflow.(12, 3, 0, 1)
```

```elixir
defmodule Maybe do
  import Fs.Option

  def _Bind(x, f) do
    case x do
      none() -> none()
      some(a) -> f.(a)
    end
  end

  def _Pure(x), do: some(x)
end
```

```elixir
divideByWorkflow = fn init, x, y, z ->
  compute Maybe do
    let! a = init |> divideBy.(x)
    let! b = a |> divideBy.(y)
    let! c = b |> divideBy.(z)
    pure c
  end
end
```

```elixir
good = divideByWorkflow.(12, 2, 3, 1)
bad  = divideByWorkflow.(12, 3, 0, 1)
```

# Chains of "or else" tests

```elixir
map1 = %{"1" => "One", "2" => "Two"}
map2 = %{"A" => "Alice", "B" => "Bob"}
map3 = %{"CA" => "California", "NY" => "New York"}

multiLookup = fn key ->
  case map1 |> tryFind(key) do
    some(result1) -> some(result1)          # success
    none() ->                               # failure
      case map2 |> tryFind(key) do
        some(result2) -> some(result2)      # success
        none() ->                           # failure
          case map3 |> tryFind(key) do
            some(result3) -> some(result3)  # success
            none() -> none()                # failure
          end
      end
  end
end
```

```elixir
multiLookup.("A")  |> IO.inspect(label: "Result for A is")
multiLookup.("CA") |> IO.inspect(label: "Result for CA is")
multiLookup.("X")  |> IO.inspect(label: "Result for X is")
```

```elixir
defmodule OrElse do
  def _PureFrom(x), do: x
  def _Combine(a, b) do
    case a do
      some(_) -> a # a succeeds -- use it
      none() -> b  # a fails -- use b instead
    end
  end
  def _Delay(f), do: f.()
end
```

```elixir
map1 = %{"1" => "One", "2" => "Two"}
map2 = %{"A" => "Alice", "B" => "Bob"}
map3 = %{"CA" => "California", "NY" => "New York"}

multiLookup = fn key ->
  compute OrElse do
    pure! map1 |> tryFind(key)
    pure! map2 |> tryFind(key)
    pure! map3 |> tryFind(key)
  end
end
```

```elixir
multiLookup.("A")  |> IO.inspect(label: "Result for A is")
multiLookup.("CA") |> IO.inspect(label: "Result for CA is")
multiLookup.("X")  |> IO.inspect(label: "Result for X is")
```

# Next

2. [Understanding continuations](02-understanding-continuations.md)
