defmodule CeExamplesTest do
  use ExUnit.Case
  doctest CeExamples

  test "greets the world" do
    assert CeExamples.hello() == :world
  end
end
