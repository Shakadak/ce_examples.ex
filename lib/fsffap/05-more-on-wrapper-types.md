Open a session with `iex -S mix`.  
You can then copy-paste the code, or write it yourself.  

```elixir
import ComputationExpression
import Fs.Option
import Fs.Map
```

[Series link](README.md)  
[Original article](https://fsharpforfunandprofit.com/posts/computation-expressions-wrapper-types-part2/)

# Previous

4: [Computation expressions and wrapper types](04-computation-expressions-and-wrapper-types.md)
6: [Implementing a CE: Zero and Yield](06-implementing-a-ce-zero-and-yield.md)

# What kinds of types can be wrapper types ?

# Can non-generic wrapper types work ?

<skipped>

# Rules for workflows that use wrapper types

```elixir
# fragment before refactoring
compute MyWorkflow do
  wrapped = # some wrapped value
  let! unwrapped = wrapped
  pure unwrapped
end

# refactored fragment
compute MyWorkflow do
  wrapped = # some wrapped value
  pure! unwrapped
end
```

## Rule 1 : left identity

```elixir
compute MyWorkflow do
  originalUnwrapped = something
  wrapped = compute MyWorkflow, do: pure originalUnwrapped
  let! newUnwrapped = wrapped
  ^newUnwrapped = originalUnwrapped
end
```

## Rule 2 : right identity

```elixir
compute MyWorkflow do
  originalWrapped = something
  newWrapped = compute MyWorkflow do
    # unwrap it
    let! unwrapped = originalWrapped
    # wrap it
    pure unwrapped
  end

  ^newWrapped = originalWrapped
end
```

## Rule 3 : associativity

```elixir
# inlined
result1 = compute MyWorkflow do
  let! x = originalWrapped
  let! y = f.(x)
  pure! g.(y)
end

# using a child workflow ("extraction" refactoring)
result2 = compute MyWorkflow do
  let! y = compute MyWorkflow do
    let! x = originalWrapped
    pure! f.(x)
  end
  pure! g.(y)
end

^result1 = result2
```

# Lists as  wrapper types

```elixir
bind.([1, 2, 3], fn elem -> expression using a single element end)
```

```elixir
add =
  bind.([1, 2, 3], fn elem1 ->
  bind.([10, 11, 12], fn elem2 ->
  elem1 + elem2
  end) end)
```

```elixir
bind.([1, 2, 3], fn elem -> expression using a single element, returning a list end)
```

```elixir
add =
  bind.([1, 2, 3], fn elem1 ->
  bind.([10, 11, 12], fn elem2 ->
  [elem1 + elem2] # a list !
  end) end)
```

```elixir
bind = fn list, f ->
  # 1) for each element in list, apply f
  # 2) f will return a list (as required by its signature)
  # 3) the result is a list of lists
end
```

```elixir
bind = fn list, f ->
  list
  |> Enum.map(f)
  |> Enum.concat()
end

add =
  bind.([1, 2, 3], fn elem1 ->
  bind.([10, 11, 12], fn elem2 ->
  # elem1 + elem2 # error
  [elem1 + elem2] # correctly returns a list
  end) end)
```

```elixir
defmodule ListWorkflowBuilder do
  def _Bind(list, f) do
    list |> Enum.flat_map(f)
  end

  def _Pure(x), do: [x]
end
alias ListWorkflowBuilder, as: List
```

```elixir
added = compute List do
  let! i = [1, 2, 3]
  let! j = [10, 11, 12]
  pure i + j
end
|> IO.inspect(label: "added=")

multiplied = compute List do
  let! i = [1, 2, 3]
  let! j = [10, 11, 12]
  pure i * j
end
|> IO.inspect(label: "multiplied=")
```

```elixir

```

# Next

4: [Computation expressions and wrapper types](04-computation-expressions-and-wrapper-types.md)
6: [Implementing a CE: Zero and Yield](06-implementing-a-ce-zero-and-yield.md)
