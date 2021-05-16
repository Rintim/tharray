defmodule Array.Implementations.ErlangArray do
  @moduledoc """
  Wraps the Erlang `:array` module.
  (See: http://erlang.org/doc/man/array.html)
  """

  @behaviour Array.Behaviour

  alias __MODULE__

  defstruct contents: nil, length: 0

  @impl Array.Behaviour
  # {:default, val} and {:size, num} are forwarded to `:array`
  def new(options) do
    contents = :array.new([{:fixed, false} | options] ++ [default: nil])
    %ErlangArray{contents: contents, length: :array.size(contents)}
  end

  @impl Array.Behaviour
  def new(enumration, options) do
    contents = :array.from_list(enumration |> Enum.to_list, Access.get(options, :default, nil))
    %ErlangArray{contents: contents, length: :array.size(contents)}
  end

  @behaviour Access

  @impl Access
  def fetch(%ErlangArray{contents: contents, length: length}, index) when index >= 0 do
    if index >= length do
      :error
    else
      {:ok, :array.get(contents, index)}
    end
  end

  def fetch(%ErlangArray{contents: contents, length: length}, index) when index < 0 do
    if index < -length do
      :error
    else
      {:ok, :array.get(index + length, contents)}
    end
  end

  @impl Access
  def get_and_update(array = %ErlangArray{contents: contents, length: length}, index, function) when index >= 0 do
    if index >= length do
      {res, _} = function.(nil)
      {res, array}
    else
      value = :array.get(contents, index)

      case function.(value) do
        :pop ->
          new_contents = :array.reset(index, contents)
          {value, %ErlangArray{array | contents: new_contents}}

        {get, new_value} ->
          new_contents = :array.set(index, new_value, contents)
          {get, %ErlangArray{array | contents: new_contents}}
      end
    end
  end

  @impl Access
  def get_and_update(array = %ErlangArray{length: length}, index, function) when index < 0 do
    if index < -length do
      {res, _} = function.(nil)
      {res, array}
    else
      get_and_update(array, index + length, function)
    end
  end

  @impl Access
  def pop(array = %ErlangArray{contents: contents, length: length}, index) when index >= 0 do
    new_index = index + map_size(contents)
    value = :array.get(new_index, contents)
    new_contents = :array.reset(new_index, contents)
    {value, %ErlangArray{array | contents: new_contents, length: length - 1}}
  end

  def pop(array = %ErlangArray{length: length}, index) when index < 0 do
    pop(array, index + length)
  end

  defimpl Array.Protocol do
    alias Array.Implementations.ErlangArray

    @impl true
    def length(%ErlangArray{length: length}), do: length

    @impl true
    def fetch(array, index) do
      try do
        {:ok, :array.get(index, array)}
      rescue
        _e in ArgumentError ->
          nil
      end
    end

    def get(%ErlangArray{contents: contents, length: length}, index) do
      if index < 0 do
        :array.get(index + length, contents)
      else
        :array.get(contents, index)
      end
    end

    @impl true
    defdelegate replace(array, index, element), to: __MODULE__, as: :set

    def set(array = %ErlangArray{contents: contents, length: length}, index, item) do
      new_contents =
        if index < 0 do
          :array.set(index + length, item, contents)
        else
          :array.set(index, item, contents)
        end

      %ErlangArray{array | contents: new_contents}
    end

    @impl true
    def empty(array = %ErlangArray{contents: contents, length: length}) do
      new_contents =
        Enum.reduce(0..length - 1, contents, fn index, array ->
          :array.reset(index, array)
        end)

      %ErlangArray{array | contents: new_contents}
    end
    @impl true
    def extract(array = %ErlangArray{contents: contents, length: length}) do
      case length do
        0 ->
          :none

        size ->
          index = size - 1
          elem = :array.get(index, contents)
          contents_rest = :array.resize(index, contents)
          array_rest = %ErlangArray{array | contents: contents_rest}
          {:ok, {elem, array_rest}}
      end
    end

    @impl true
    def iter(array = %ErlangArray{contents: contents}) do
      case :array.size(contents) do
        0 ->
          :none

        size ->
          elem = :array.get(0, contents)
          contents_rest = :array.resize(size - 1, contents)
          array_rest = %ErlangArray{array | contents: contents_rest}
          {:ok, {elem, array_rest}}
      end
    end

    @impl true
    def to_list(%ErlangArray{contents: contents}) do
      :array.to_list(contents)
    end
  end
end
