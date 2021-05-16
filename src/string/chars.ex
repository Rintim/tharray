for module <- [
  Array.Implementations.ErlangArray,
  Array.Implementations.MapArray
] do
  defimpl String.Chars, for: module do
    def to_string(array), do: "#Array<#{Array.Protocol.to_list(array) |> inspect}>"
  end
end
