defmodule IdentityBuilder do
  def _Bind(m, f), do: f.(m)
  def _Pure(x), do: x
  def _PureFrom(x), do: x
end

defmodule IdentityExample do
  import ComputationExpression

  def result do
    compute IdentityBuilder do
      let! x = 1
      let! y = 2
      pure x + y
    end
    |> IO.inspect(label: "result=" )
  end
end
