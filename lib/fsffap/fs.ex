defmodule Fs.Option do
  defmacro some(x), do: {:some, x}
  defmacro none, do: :none

  def bind(f, m) do
    case m do
      none() -> none()
      some(x) -> x |> f.()
    end
  end
end

defmodule Fs.Map do
  import Fs.Option

  def tryFind(m, k) do
    case Map.fetch(m, k) do
      {:ok, v} -> some(v)
      :error -> none()
    end
  end
end
