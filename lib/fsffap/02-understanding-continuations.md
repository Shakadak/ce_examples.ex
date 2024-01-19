Open a session with `iex -S mix`.  
You can then copy-paste the code, or write it yourself.  

```elixir
import ComputationExpression
import Fs.Option
import Fs.Map
```

[Series link](README.md)  
[Original article](https://fsharpforfunandprofit.com/posts/computation-expressions-continuations/)

# Previous

1: [Computation expressions: Introduction](01-computation-expressions-introduction.md) 
3: [Introducing 'bind'](03-introducting-bind.md)

# Recap

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
loggedWorkflow = compute Logging do
  let! x = 42
  let! y = 43
  let! z = x + y
  pure z
end
```

# Continuations

```elixir
divide = fn top, bottom ->
  if bottom == 0 do
    raise ArgumentError, message: "div by 0"
  else
    top / bottom
  end
end

isEven = fn aNumber -> aNumber |> rem(2) == 0 end
```

```elixir
divide = fn top, bottom, ifZero, ifSuccess ->
  if bottom == 0 do
    ifZero.()
  else
    ifSuccess.(top / bottom)
  end
end

isEven = fn aNumber, ifOdd, ifEven ->
  if aNumber |> rem(2) == 0 do
    aNumber |> ifEven.()
  else
    aNumber |> ifOdd.()
  end
end
```

# Continuation examples

```elixir
# Scenario 1: pipe the result into a message
# ----------------------------------------
# setup the functions to print a message
ifZero1 = fn -> :ok = IO.puts("bad") ; {} end
ifSuccess1 = fn x -> :ok = IO.puts("good #{inspect(x)}") ; {} end

# use partial application
divide1 = &divide.(&1, &2, ifZero1, ifSuccess1)

# test
good1 = divide1.(6, 3)
bad1 = divide1.(6, 0)

# Scenario 2: convert the result to an option
# ----------------------------------------
# setup the functions to return an Option
ifZero2 = fn -> none() end
ifSuccess2 = fn x -> some(x) end
divide2 = &divide.(&1, &2, ifZero2, ifSuccess2)

# test
good2 = divide2.(6, 3)
bad2 = divide2.(6, 0)

# Scenario 3: throw an exception in the bad case
# ----------------------------------------
# setup the functions to throw exception
ifZero3 = fn -> raise "div by 0" end
ifSuccess3 = fn x -> x end
divide3 = &divide.(&1, &2, ifZero3, ifSuccess3)

# test
good3 = divide3.(6, 3)
bad3 = divide3.(6, 0)
```

```elixir
# Scenario 1: pipe the result into a message
# ----------------------------------------
# setup the functions to print a message
ifOdd1 = fn x -> :ok = IO.puts("isOdd #{inspect(x)}") ; {} end
ifEven1 = fn x -> :ok = IO.puts("isEven #{inspect(x)}") ; {} end

# use partial application
isEven1 = &isEven.(&1, ifOdd1, ifEven1)

# test
good1 = isEven1.(6)
bad1  = isEven1.(5)

# Scenario 2: convert the result to an option
# ----------------------------------------
# setup the functions to return an Option
ifOdd2 = fn _ -> none() end
ifEven2 = fn x -> some(x) end
isEven2 = &isEven.(&1, ifOdd2, ifEven2)

# test
good2 = isEven2.(6)
bad2  = isEven2.(5)

# Scenario 3: throw an exception in the bad case
# ----------------------------------------
ifOdd3 = fn _ -> raise "assert failed" end
ifEven3 = fn x -> x end
isEven3 = &isEven.(&1, ifOdd3, ifEven3)

# test
good3 = isEven3.(6)
bad3  = isEven3.(5)
```

```elixir
createEmailAdressWithContinuation = fn "" <> s, success, failure ->
  if Regex.match?(~r/^\S+@\S+\.\S+$/, s) do
    success.({:EmailAddress, s})
  else
    failure.("Email address must contain an @ sign")
  end
end
```

```elixir
# setup the functions
success = fn {:EmailAddress, s} -> :ok = IO.puts("success creating email #{s}") ; {} end
failure = fn msg -> :ok = IO.puts("error creating email: #{msg}") ; {} end
createEmail = &createEmailAdressWithContinuation.(&1, success, failure)

# test
goodEmail = createEmail.("x@example.com")
badEmail  = createEmail.("example.com")
```

# Continuation passing style

# Continuations and 'let'

```elixir
let x = someExpression
```

```elixir
let x = someExpression ; [an expression involving x]
```

```elixir
x = 42
y = 43
z = z + y
```

```elixir
x = 42
; y = 43
; z = x + y
; z
```

```elixir
fn x -> [an expression involving x] end
```

```elixir
someExpression |> (fn x -> [an expression involving x] end).()
someExpression |> then(fn x -> [an expression involving x] end)
```

```elixir
# let
x = someExpression ; [an expression involving x]

# pipe a value into a lambda
someExpression |> (fn x -> [an expression involving x] end).()
```

```elixir
42 |> then(fn x ->
  43 |> then(fn y ->
    x + y |> then(fn z ->
      z
    end)
  end)
end)
```

# Wrapping the continuation in a function

```elixir
pipeInto = fn someExpression, lambda ->
  someExpression |> lambda.()
end
```

```elixir
pipeInto.(42, fn x ->
  pipeInto.(43, fn y ->
    pipeInto.(x + y, fn z ->
      z
    end)
  end)
end)
```

```elixir
pipeInto.(42, fn x ->
pipeInto.(43, fn y ->
pipeInto.(x + y, fn z ->
z
end) end) end)
```

# The "logging" example revisited

```elixir
pipeInto = fn someExpression, lambda ->
  :ok = IO.puts("expression is #{inspect(someExpression)}")
  someExpression |> lambda.()
end
```

```elixir
pipeInto.(42, fn x ->
pipeInto.(43, fn y ->
pipeInto.(x + y, fn z ->
z
end) end) end)
```

# The "safe divide" example revisited

```elixir
divideBy = fn top, bottom ->
  if bottom == 0 do
    none()
  else
    some(top / bottom)
  end
end

divideByWorkflow = fn x, y, w, z ->
  a = x |> divideBy.(y)
  case a do
    none() -> none() # give up
    some(a1) ->      # keep going
      b = a1 |> divideBy.(w)
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
pipeInto = fn someExpression, lambda ->
  case someExpression do
    none() -> none()
      some(x) -> x |> lambda.()
  end
end
```

```elixir
divideByWorkflow = fn x, y, w, z ->
  a = z |> divideBy.(y)
  pipeInto.(a, fn a1 ->
    b = a1 |> divideBy.(w)
    pipeInto.(b, fn b1 ->
      c = b1 |> divideBy.(z)
      pipeInto.(c, fn c1 ->
        some(c1) # return
      end)
    end)
  end)
end
```

```elixir
a = x |> divideBy.(y)
pipeInto.(a, fn a1 ->
```

```elixir
pipeInto.(x |> divideBy.(y), fn a1 ->
```

```elixir
divideByResult = fn x, y, w, c ->
  pipeInto.(x |> divideBy.(y), fn a ->
  pipeInto.(a |> divideBy.(w), fn b ->
  pipeInto.(b |> divideBy.(z), fn c ->
  some(c) # return
  end) end) end)
end
```

```elixir
divideBy = fn top, bottom ->
  if bottom == 0 do
    none()
  else
    some(top / bottom)
  end
end

pipeInto = fn someExpression, lambda ->
  case someExpression do
    none() -> none()
      some(x) -> x |> lambda.()
  end
end

pure1 = fn c -> some(c) end

divideByWorkflow = fn x, y, w, z ->
  pipeInto.(x |> divideBy.(y), fn a ->
  pipeInto.(a |> divideBy.(w), fn b ->
  pipeInto.(b |> divideBy.(z), fn c ->
  pure1.(c)
  end) end) end)
end

good = divideByWorkflow.(12, 3, 2, 1)
bad  = divideByWorkflow.(12, 3, 0, 1)
```

# Next

1: [Computation expressions: Introduction](01-computation-expressions-introduction.md) 
3: [Introducing 'bind'](03-introducting-bind.md)
