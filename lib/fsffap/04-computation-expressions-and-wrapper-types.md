Open a session with `iex -S mix`.  
You can then copy-paste the code, or write it yourself.  

```elixir
import ComputationExpression
import Fs.Option
import Fs.Map
```

[Series link](README.md)  
[Original article](https://fsharpforfunandprofit.com/posts/computation-expressions-wrapper-types/)

# Previous

3: [Introducing 'bind'](03-introducing-bind.md)
5: [More on wrapper types](05-more-on-wrapper-types.md)

# Recap

```elixir
result = compute Maybe do
  let! anInt  = expression of option(int)
  let! anInt2 = expression of option(int)
  pure anInt + anInt2
end
```

# Another Example

```elixir
defmodule DbResult do
  defmacro success(a), do: {:success, a}
  defmacro error(string), do: {:error, string}
end
```

```elixir
defmodule DbDomain do
  import DbResult

  def getCustomerId(name) do
    if name == "" do
      error("getCustomerId failed")
    else
      success("Cust42")
    end
  end

  def getLastOrderForCustomer(custId) do
    if custId == "" do
      error("getLastOrderForCustomer failed")
    else
      success("Order123")
    end
  end

  def getLastProductForOrder(orderId) do
    if orderId == "" do
      error("getLastProductForOrder failed")
    else
      success("product456")
    end
  end
end
```

```elixir
defmodule DbExplicit do
  import DbResult
  import DbDomain

  def product do
    r1 = getCustomerId "Alice"
    case r1 do
      error _ -> r1
      success custId ->
        r2 = getLastOrderForCustomer custId
        case r2 do
          error _ -> r2
          success orderId ->
            r3 = getLastProductForOrder orderId
            case r3 do
              error _ -> r3
              success productId ->
                :ok = IO.puts("Product is #{productId}")
                r3
            end
        end
    end
  end
end
```

```elixir
defmodule DbResultBuilder do
  import DbResult

  def _Bind(m, f) do
    case m do
      error _ -> m
      success a ->
        :ok = IO.puts("\tSuccessful: #{a}")
        f.(a)
    end
  end

  def _Pure(x), do: success x
end
```

```elixir
defmodule DbCompExpr do
  import ComputationExpression


  import DbDomain

  def product1 do
    compute DbResultBuilder do
      let! custId = getCustomerId "Alice"
      let! orderId = getLastOrderForCustomer custId
      let! productId = getLastProductForOrder orderId
      :ok = IO.puts("Product is #{productId}")
      pure productId
    end
  end

  def product2 do
    compute DbResultBuilder do
      let! _custId = getCustomerId "Alice"
      let! orderId = getLastOrderForCustomer "" # error !
      let! productId = getLastProductForOrder orderId
      :ok = IO.puts("Product is #{productId}")
      pure productId
    end
  end

  def good, do: product1() |> IO.inspect()
  def bad,  do: product2() |> IO.inspect()
end
```

# The role of wrapper types in workflows

# Bind and Pure and wrapper types

```elixir
# pure for the maybe workflow
def _Pure(x), do: some(x)

# pure for the dbresult workflow
def _Pure(x), do: success(x)
```

```elixir
# bind for the maybe workflow
def bind(m, f) do
  case m do
    none() -> none()
    some(x) -> f.(x)
  end
end

# bind for the dbresult workflow
def bind(m, f) do
  case m do
    error(_) -> m
    success(x) ->
      :ok = IO.puts("Successful: #{inspect(x)}")
      f.(x)
  end
end
```

# The type wrapper is generic

```elixir
defmodule DbResult do
  defmacro success(a),      do: {:success, a}
  defmacro error(string),   do: {:error, string}

  defmacro customerId(x),   do: {:customer_id, x}
  defmacro orderId(x),      do: {:order_id, x}
  defmacro productId(x),    do: {:product_id, x}
end
import DbResult
```

```elixir
getCustomerId = fn name ->
  if name == "" do
    error("getCustomerId failed")
  else
    success(customerId, "Cust42")
  end
end

getLastOrderForCustomer = fn {:customer_id, custId} ->
  if custId == "" do
    error("getLastOrderForCustomer failed")
  else
    success(order_id("Order123")
  end
end

getLastProductForOrder = fn {:order_id, orderId} ->
  if orderId == "" do
    error("getLastProductForOrder failed")
  else
    success(productId("product456"))
  end
end
```

```elixir
product = fn ->
  r1 = getCustomerId.("Alice")
  case r1 do
    error _ -> r1
    success custId ->
      r2 = getLastOrderForCustomer.(custId)
      case r2 do
        error _ -> r2
        success orderId ->
          r3 = getLastProductForOrder.(orderId)
          case r3 do
            error _ -> r3
            success productId ->
              :ok = IO.puts("Product is #{inspect(productId)}")
              r3
          end
      end
  end
end
```

```elixir
defmodule DbResultBuilder do
  import DbResult

  def _Bind(m, f) do
    case m do
      error e -> error e
      success a ->
        :ok = IO.puts("\tSuccessful: #{a}")
        f.(a)
    end
  end

  def _Pure(x), do: success x
end
```

```elixir
product1 = compute DbResultBuilder do
  let! custId = getCustomerId.("Alice")
  let! orderId = getLastOrderForCustomer.(custId)
  let! productId = getLastProductForOrder.(orderId)
  :ok = IO.puts("Product is #{productId}")
  pure productId
end
```

```elixir
product2 = compute DbResultBuilder do
  let! _custId = getCustomerId.("Alice")
  let! orderId = getLastOrderForCustomer.("") # error !
  let! productId = getLastProductForOrder.(orderId)
  :ok = IO.puts("Product is #{productId}")
  pure productId
end
```

# Composition of computation expressions

```elixir
subworkflow1 = compute MyWorkflow, do: pure 42
subworkflow2 = compute MyWorkflow, do: pure 43

aWrappedValue = compute MyWorkflow do
  let! unwrappedValue1 = subworkflow1
  let! unwrappedValue2 = subworkflow2
  pure unwrappedValue1 + unwrappedValue2
end
```

```elixir
aWrapped = compute MyWorkflow do
  let! unwrappedValue1 = compute MyWorkflow do
    let! x = compute MyWorkflow, do: pure 1
    pure x
    end
  let! unwrappedValue2 = compute MyWorkflow do
    let! y = compute MyWorkflow, do: pure 2
    pure y
  end
  pure unwrappedValue1 + unwrappedValue2
end
```

```elixir
a = compute Async do
  let! x = doAsyncThing() # nested workflow
  let! y = doNextAsyncThing(x) # nested workflow
  pure x + y
end
```

# Introducing "PureFrom"

```elixir
defmodule Maybe do
  import Option
  def _Bind(m, f) = Option.bind(f, m)
  def _Pure(x) do
    :ok = IO.puts("Wrapping a raw value into an option")
    some(x)
  end
  def _PureFrom(m) do
    :ok = IO.puts("Returning an option directly")
    m
  end
end
```

```elixir
compute Maybe, do: pure 1
compute Maybe, do: pure! some 2
```

```elixir
# using pure
compute Maybe do
  let! x = 12 |> divideBy.(3)
  let! y = x |> divideBy.(2)
  pure y # return an in
end

# using pure!
compute Maybe do
  let! x = 12 |> divideBy.(3)
  pure! x |> divideBy.(2)
end
```

# Next

3: [Introducing 'bind'](03-introducing-bind.md)
5: [More on wrapper types](05-more-on-wrapper-types.md)
