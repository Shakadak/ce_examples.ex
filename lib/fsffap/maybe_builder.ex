defmodule MaybeBuilder do
  def _Bind(m, f), do: Option.bind(f, m)
  def _Pure(x), do: (require Option ; Option.some(x))
end
