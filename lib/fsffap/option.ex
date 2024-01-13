defmodule Option do
  defmacro some(x), do: {:some, x}
  defmacro none, do: :none

  def bind(f, m) do
    case m do
      none() -> none()
      some(x) -> x |> f.()
    end
  end
end
