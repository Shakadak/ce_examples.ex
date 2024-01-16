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
end
