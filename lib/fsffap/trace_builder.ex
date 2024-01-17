defmodule Trace do
  import Option

  def _Bind(m, f) do
    :ok = case m do
      none() -> IO.puts("Binding with None. Exiting.")
      some(a) -> IO.puts("Binding with Some(#{inspect(a)}). Continuing")
    end
    Option.bind(f, m)
  end

  def _Pure(x) do
    :ok = IO.puts("Returning a unwrapped #{inspect(x)} as an option")
    some(x)
  end

  def _PureFrom(m) do
    :ok = IO.puts("Returning an option (#{inspect(m)}) directly")
    m
  end

  def _Zero do
    :ok = IO.puts("Zero")
    none()
  end

  def _Yield(x) do
    :ok = IO.puts("Yield an unwrapped #{inspect(x)} as an option")
    some(x)
  end

  def _YieldFrom(x) do
    :ok = IO.puts("Yield an option #{inspect(x)} directly")
    some(x)
  end

  def _Combine(a, b) do
    case {a, b} do
      {some(a1), some(b1)} ->
        :ok = IO.puts("combining #{inspect(a1)} and #{inspect(b1)}")
        some(a1 + b1)

      {some(a1), none()} ->
        :ok = IO.puts("combining #{inspect(a1)} with None")
        some(a1)

      {none(), some(b1)} ->
        :ok = IO.puts("combining None with #{inspect(b1)}")
        some(b1)

      {none(), none()} ->
        :ok = IO.puts("combining None with None")
        none()
    end
  end

  def _Delay(f) do
    :ok = IO.puts("Delay")
    f.()
  end
end

defmodule TraceExample do
  import ComputationExpression
  import Option

  def ex1 do
    compute Trace do
      pure 1
    end
    |> IO.inspect(label: "Result 1")
  end

  def ex2 do
    compute Trace do
      pure! some(2)
    end
  end

  def ex3 do
    compute Trace do
      let! x = some(1)
      let! y = some(2)
      pure x + y
    end
    |> IO.inspect(label: "Result 3")
  end

  def ex4 do
    compute Trace do
      let! x = none()
      let! y = some(1)
      pure x + y
    end
    |> IO.inspect(label: "Result 4")
  end

  def ex5 do
    void = fn _ -> {} end
    compute Trace do
      do! some void.(IO.puts("...expression that returns unit"))
      do! some void.(IO.puts("...another expression that returns unit"))
      let! x = some 1
      pure x
    end
    |> IO.inspect(label: "Result from do")
  end

  def ex6 do
    compute Trace do
      IO.puts("Hello world")
    end
    |> IO.inspect(label: "Result for simple expression")
  end

  def ex7 do
    compute Trace do
      if false do pure 1 end
    end
    |> IO.inspect(label: "Result for if without else")
  end

  def ex8 do
    compute Trace do
      yield 1
    end
    |> IO.inspect(label: "Result for yield")
  end

  def ex9 do
    compute Trace do
      yield! some(1)
    end
    |> IO.inspect(label: "Result for yield!")
  end

  def ex10 do
    compute Trace do
      yield 1
      yield 2
    end
    |> IO.inspect(label: "Result for yield then yield")
  end

  def ex11 do
    compute Trace do
      pure 1
      pure 2
    end
    |> IO.inspect(label: "Result for pure then pure")
  end

  def ex12 do
    compute Trace do
      if true, do: IO.puts("hello")
      pure 1
    end
    |> IO.inspect(label: "Result for if then pure")
  end

  def ex13 do
    compute Trace do
      yield 1
      let! _x = none()
      yield 2
    end
    |> IO.inspect(label: "Result for yield then None")
  end

  def ex14 do
    compute Trace do
      yield 1
      yield 2
      yield 3
    end
    |> IO.inspect(label: "Result for yield × 3")
  end

  def ex15 do
    compute Trace do
      yield 1
      pure 2
    end
    |> IO.inspect(label: "Result for yield then pure")
  end
end

defmodule TraceAlternate do
  import Option

  def _Bind(m, f) do
    :ok = case m do
      none() -> IO.puts("Binding with None. Exiting.")
      some(a) -> IO.puts("Binding with Some(#{inspect(a)}). Continuing")
    end
    Option.bind(f, m)
  end

  def _Pure(x) do
    :ok = IO.puts("Returning a unwrapped #{inspect(x)} as an option")
    some(x)
  end

  def _PureFrom(m) do
    :ok = IO.puts("Returning an option (#{inspect(m)}) directly")
    m
  end

  def _Zero do
    :ok = IO.puts("Zero")
    none()
  end

  def _Yield(x) do
    :ok = IO.puts("Yield an unwrapped #{inspect(x)} as an option")
    some(x)
  end

  def _YieldFrom(x) do
    :ok = IO.puts("Yield an option #{inspect(x)} directly")
    some(x)
  end

  def _Combine(a, b) do
    :ok = IO.puts("combining #{inspect(a)} with #{inspect(b)}")
    case a do
      some(_) -> a
      none() -> b
    end
  end

  def _Delay(f) do
    :ok = IO.puts("Delay")
    f.()
  end
end

defmodule AlternateExample do
  import Option
  import ComputationExpression

  def parseInt(s) do
    Integer.parse(s)
    |> case do
      {i, ""} -> some({:i, i})
      :error -> none()
    end
  end

  def parseBool(s) do
    case s do
      "true" -> some({:b, true})
      "false" -> some({:b, false})
      _ -> none()
    end
  end

  def ex1 do
    compute TraceAlternate do
      pure! parseBool("42") # fails
      pure! parseInt("42")
    end
    |> IO.inspect(label: "Result for parsing")
  end

  def tryFind(m, k) do
    case Map.fetch(m, k) do
      {:ok, v} -> some(v)
      :error -> none()
    end
  end

  def ex2 do
    map1 = %{"1" => "One", "2" => "Two"}
    map2 = %{"A" => "Alice", "B" => "Bob"}
    compute TraceAlternate do
      pure! map1 |> tryFind("A")
      pure! map2 |> tryFind("A")
    end
    |> IO.inspect(label: "Result for map lookup")
  end
end

defmodule TraceCont do
  import Option

  def _Bind(m, f) do
    :ok = case m do
      none() -> IO.puts("Binding with None. Exiting.")
      some(a) -> IO.puts("Binding with Some(#{inspect(a)}). Continuing")
    end
    Option.bind(f, m)
  end

  def _Pure(x) do
    :ok = IO.puts("Returning a unwrapped #{inspect(x)} as an option")
    some(x)
  end

  def _PureFrom(m) do
    :ok = IO.puts("Returning an option (#{inspect(m)}) directly")
    m
  end

  def _Zero do
    :ok = IO.puts("Zero")
    _Pure({})
  end

  def _Yield(x) do
    :ok = IO.puts("Yield an unwrapped #{inspect(x)} as an option")
    some(x)
  end

  def _YieldFrom(x) do
    :ok = IO.puts("Yield an option #{inspect(x)} directly")
    some(x)
  end

  def _Combine(a, b) do
    :ok = IO.puts("combining #{inspect(a)} with #{inspect(b)}")
    _Bind(a, fn {} -> b end)
  end

  def _Delay(f) do
    :ok = IO.puts("Delay")
    f.()
  end
end

defmodule TraceContExample do
  import ComputationExpression

  def ex1 do
    compute TraceCont do
      ignore = fn _ -> {} end
      if true do ignore.(IO.puts("hello.........")) end
      if false do ignore.(IO.puts("........world")) end
      pure 1
    end
    |> IO.inspect(label: "Result for sequential combine")
  end
end

defmodule TraceNoBind do
  import Option

  def _PureFrom(m), do: m
  def _Zero, do: some {}
  def _Combine(a, b), do: Option.bind(fn {} -> b end, a)
  def _Delay(f), do: f.()
end

defmodule TraceNoBindExample do
  def ex1 do
    import Option
    import ComputationExpression
    compute TraceNoBind do
      let ignore = fn _ -> {} end
      if true do ignore.(IO.puts("hello.........")) end
      if false do ignore.(IO.puts("........world")) end
      pure! some(1)
    end
    |> IO.inspect(label: "Result for minimal combine")
  end
end
