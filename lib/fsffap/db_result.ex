defmodule DbResult do
  defmacro success(a), do: {:success, a}
  defmacro error(string), do: {:error, string}
end

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

defmodule DbResultBuilder do
  use ComputationExpression

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

defmodule DbCompExpr do
  require DbResultBuilder

  import DbDomain

  def product1 do
    DbResultBuilder.compute do
      let! custId = getCustomerId "Alice"
      let! orderId = getLastOrderForCustomer custId
      let! productId = getLastProductForOrder orderId
      :ok = IO.puts("Product is #{productId}")
      pure productId
    end
  end

  def product2 do
    DbResultBuilder.compute do
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

defmodule DbResultBuilder2 do
  use ComputationExpression

  import DbResult

  def _Bind(m, f) do
    case m do
      error _ -> m
      success a ->
        :ok = IO.puts("\tSuccessful: #{inspect(a)}")
        f.(a)
    end
  end

  def _Pure(x), do: success x
end

defmodule DbCompExpr2 do
  require DbResultBuilder2

  import DbResult

  def getCustomerId(name) do
    if name == "" do
      error("getCustomerId failed")
    else
      success({:customer_id, "Cust42"})
    end
  end

  def getLastOrderForCustomer({:customer_id, custId}) do
    if custId == "" do
      error("getLastOrderForCustomer failed")
    else
      success({:order_id, "Order123"})
    end
  end

  def getLastProductForOrder({:order_id, orderId}) do
    if orderId == "" do
      error("getLastProductForOrder failed")
    else
      success({:product_id, "product456"})
    end
  end

  def product1 do
    DbResultBuilder2.compute do
      let! custId = getCustomerId "Alice"
      let! orderId = getLastOrderForCustomer custId
      let! productId = getLastProductForOrder orderId
      :ok = IO.puts("Product is #{inspect(productId)}")
      pure productId
    end
  end

  def product2 do
    DbResultBuilder2.compute do
      let! _custId = getCustomerId "Alice"
      let! orderId = getLastOrderForCustomer {:customer_id, ""} # error
      let! productId = getLastProductForOrder orderId
      :ok = IO.puts("Product is #{productId}")
      pure productId
    end
  end

  def good, do: product1() |> IO.inspect()
  def bad,  do: product2() |> IO.inspect()
end
