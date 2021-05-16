for module <- [
  Array.Implementations.ErlangArray,
  Array.Implementations.MapArray
] do
  defimpl Enumerable, for: module do
    @spec member?(any, integer) :: {:ok, boolean}
    def member?(array, item) do #{:error, unquote(module)}
      state = Array.Protocol.fetch(array, item)
      case state do
        {:ok, _value} ->
          {:ok, true}
        nil ->
          {:ok, false}
      end
    end

    def count(array) do
      {:ok, Array.Protocol.length(array)}
    end

    def reduce(array, state, fun), do: Enumerable.List.reduce(Array.Protocol.to_list(array), state, fun)

    def slice(array) do
      size = Array.Protocol.length(array)
      {:ok, size, &Enumerable.List.slice(Array.Protocol.to_list(array), &1, &2, size)}
    end
  end
end
