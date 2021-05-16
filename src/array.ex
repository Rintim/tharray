defmodule Array do
  import Standard

  begin "Module Info" do
    @moduledoc """
    A Well-structured Array Based On \"Arrays\"
    """
  end

  # Other File's Format will be done next version

  begin "Type Defination" do
    @type array :: Array.Protocol.t()
    @type index :: Array.Protocol.index()
    @type value :: Array.Protocol.value()
  end

   @default_array_implementation Array.Implementations.MapArray

  begin "Function Defination" do



    def new(acc, default \\ nil), do: new_in(:map, acc ,default)
    # def new(size, default) when is_integer(size), do: @default_array_implementation.new([default: default, size: size])
    # def new(enumerable, default) when is_list(enumerable), do: from(enumerable, default)
    # def new(array = %Array.Implementations.MapArray{}, default), do: %Array.Implementations.MapArray{array | default: default}

    def new_in(type, acc, default \\ nil)
    def new_in(:map, size, default) when is_integer(size), do: @default_array_implementation.new([default: default, size: size])
    def new_in(:map, enumerable, default) when is_list(enumerable), do: from(enumerable, default)
    def new_in(:map, array = %Array.Implementations.MapArray{}, default), do: %Array.Implementations.MapArray{array | default: default}
    def new_in(:map, array = %Array.Implementations.ErlangArray{}, default), do: @default_array_implementation.new(array, [default: default])
    def new_in(:erl, size, default) when is_integer(size), do: Array.Implementations.ErlangArray.new([default: default, size: size])
    def new_in(:erl, enumerable, default) when is_list(enumerable), do: from_in(:erl, enumerable, default)
    def new_in(:erl, array = %Array.Implementations.MapArray{}, default), do: Array.Implementations.ErlangArray.new(array, [default: default])
    def new_in(:erl, array = %Array.Implementations.ErlangArray{}, default), do: Array.Implementations.ErlangArray.new(array, [default: default])
    # def new(:map, size, default), do: Array.Implementations

    #def from(enumerable), do: @default_array_implementation.new(enumerable, [])

    def from(enumerable, default \\ nil), do: from_in(:map, enumerable, default)

    def from_in(type, enumerable, default \\ nil)
    def from_in(:map, enumerable, default), do: @default_array_implementation.new(enumerable, [default: default])
    def from_in(:erl, enumerable, default), do: Array.Implementations.ErlangArray.new(enumerable, [default: default])

    def fetch!(array, index) when is_integer(index) do
      case Array.Protocol.fetch(array, index) do
        {:ok, value} -> value
        nil -> raise Enum.OutOfBoundsError
      end
    end

    def at(array, index, default \\ nil)
    def at(array, index, default) when is_integer(index) do
      case Array.Protocol.fetch(array, index) do
        {:ok, value} -> value
        nil -> default
      end
    end

    def replace_range(array, range, enumerable) do
      Enum.zip(range, enumerable)
      |> Enum.reduce(array, fn {index, item}, array ->
        Array.replace(array, index, item)
      end)
    end
  end

  begin "Aliases Defination" do
    @spec length(array) :: non_neg_integer
    defdelegate length(array), to: Array.Protocol

    @spec fetch(any, integer) :: nil | {:ok, any}
    defdelegate fetch(array, index), to: Array.Protocol

    @spec replace(array, index, value :: any) :: array
    defdelegate replace(array, index, value), to: Array.Protocol
    @spec empty(array) :: array
    defdelegate empty(array), to: Array.Protocol

    @spec extract(array) :: {:ok, {item :: any, array}} | {:error, :empty}
    defdelegate extract(array), to: Array.Protocol

    @spec to_list(array) :: list
    defdelegate to_list(array), to: Array.Protocol

    @spec iter(array) :: {:ok, {item :: value, array}} | :none
    defdelegate iter(array), to: Array.Protocol
  end
end
