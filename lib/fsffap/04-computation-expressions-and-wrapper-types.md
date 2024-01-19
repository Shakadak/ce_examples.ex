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

# Next

3: [Introducing 'bind'](03-introducing-bind.md)
5: [More on wrapper types](05-more-on-wrapper-types.md)
