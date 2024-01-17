defmodule ListWorkflowBuilder do
  def _Bind(list, f) do
    list |> Enum.flat_map(f)
  end

  def _Pure(x), do: [x]

  def _PureFrom(m), do: m

  def _Zero do
    :ok = IO.puts("Zero")
    []
  end

  def _Yield(x) do
    :ok = IO.puts("Yield an unwrapped #{inspect(x)} as a list")
    [x]
  end

  def _YieldFrom(m) do
    :ok = IO.puts("Yield a list (#{inspect(m)}) directly")
    m
  end

  def _For(m, f) do
    :ok = IO.puts("For #{inspect(m)}")
    _Bind(m, f)
  end

  def _Combine(a, b) do
    :ok = IO.puts("combining #{inspect(a)} and #{inspect(b)}")
    Enum.concat([a, b])
  end

  def _Delay(f) do
    :ok = IO.puts("Delay")
    f.()
  end
end

defmodule ListExample do
  alias ListWorkflowBuilder, as: List

  import ComputationExpression

  def added do
    compute List do
      let! i = [1, 2, 3]
      let! j = [10, 11, 12]
      pure i + j
    end
    |> IO.inspect(label: "added=")
  end

  def multiplied do
    compute List do
      let! i = [1, 2, 3]
      let! j = [10, 11, 12]
      pure i * j
    end
    |> IO.inspect(label: "multiplied=")
  end

  def ex1 do
    compute List do
      yield 1
      yield 2
    end
    |> IO.inspect(label: "Result from yield then yield")
  end

  def ex2 do
    compute List do
      yield 1
      yield! [2, 3]
    end
    |> IO.inspect(label: "Result for yield then yield!")
  end

  def ex3 do
    compute List do
      let! x = 1..3
      let! y = [10, 20, 30]
      pure x + y
    end
    |> IO.inspect(label: "Return")
  end

  def ex4 do
    compute List do
      for x in 1..3 do
        for y in [10, 20, 30] do
          pure x + y
        end
      end
    end
    |> IO.inspect(label: "Return")
  end

  def ex5 do
    compute List do
      let! i = ["red", "blue"]
      yield i
      let! j = ["hat", "tie"]
      yield! [i <> " " <> j, "-"]
    end
    |> IO.inspect(label: "Result for for..in..do")
  end

  def ex5_1 do
    compute List do
      let! i = ["red", "blue"]
      pure i
      let! j = ["hat", "tie"]
      pure! [i <> " " <> j, "-"]
    end
    |> IO.inspect(label: "Result for for..in..do")
  end

  def ex6 do
    compute List do
      yield 1
      yield 2
      yield 3
      yield 4
    end
    |> IO.inspect(label: "Result for yield × 4")
  end
end

defmodule ListMinimal do
  def _Yield(x), do: [x]
  def _For(m, f), do: m |> Enum.flat_map(f)
  def _Combine(a, b), do: Enum.concat(a, b)
  def _Delay(f), do: f.()
end

defmodule ListMinimalExample do
  import ComputationExpression

  def ex1 do
    compute ListMinimal do
      yield 1
      yield 2
    end
    |> IO.inspect(label: "Result")
  end

  def ex2 do
    compute ListMinimal do
      for i in 1..5, do: yield i + 2
      yield 42
    end
    |> IO.inspect(label: "Result")
  end
end
