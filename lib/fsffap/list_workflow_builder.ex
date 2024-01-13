defmodule ListWorkflowBuilder do
  def _Bind(list, f) do
    list |> Enum.flat_map(f)
  end

  def _Pure(x), do: [x]
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
end
