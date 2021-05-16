for module <- [
  Array.Implementations.ErlangArray,
  Array.Implementations.MapArray
] do
  defimpl Inspect, for: module do
    import Inspect.Algebra

    def inspect(array, opts) do
      concat([
        "#Array<",
        Inspect.List.inspect(Array.Protocol.to_list(array), opts),
        ">"
      ])
    end
  end
end
