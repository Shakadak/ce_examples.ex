defmodule TraceBuilder do
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
end

defmodule TraceExample do
  import ComputationExpression
  import Option

  def ex1 do
    compute TraceBuilder do
      pure 1
    end
    |> IO.inspect(label: "Result 1")
  end

  def ex2 do
    compute TraceBuilder do
      pure! some(2)
    end
  end

  def ex3 do
    compute TraceBuilder do
      let! x = some(1)
      let! y = some(2)
      pure x + y
    end
    |> IO.inspect(label: "Result 3")
  end

  def ex4 do
    compute TraceBuilder do
      let! x = none()
      let! y = some(1)
      pure x + y
    end
    |> IO.inspect(label: "Result 4")
  end

  def ex5 do
    void = fn _ -> {} end
    compute TraceBuilder do
      do! some void.(IO.puts("...expression that returns unit"))
      do! some void.(IO.puts("...another expression that returns unit"))
      let! x = some 1
      pure x
    end
    |> IO.inspect(label: "Result from do")
  end

  def ex6 do
    compute TraceBuilder do
      IO.puts("Hello world")
    end
    |> IO.inspect(label: "Result for simple expression")
  end

  def ex7 do
    compute TraceBuilder do
      if false, do: pure 1
    end
    |> IO.inspect(label: "Result for if without else")
  end
end
