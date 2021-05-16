defmodule Array.Implementations.MapArray do
  @moduledoc """
  An array implementation based on the built-in Map structure.
  """

  @behaviour Array.Behaviour

  alias __MODULE__

  defstruct contents: %{}, default: nil, length: 0

  @impl Array.Behaviour
  def new(options) do
    default = Keyword.get(options, :default, nil)
    size = Keyword.get(options, :size, 0)
    %MapArray{contents: construct(default, size), default: default, length: size}
  end

  @impl Array.Behaviour
  def new(enumerable, options) do
    default = Keyword.get(options, :default, nil)
    # Keyword.get(options, :size, 0)
    size = Enum.count(enumerable)

    %MapArray{
      contents:
        for({index, value} <- Enum.zip(0..size, enumerable), into: %{}, do: {index, value}),
      default: default,
      length: size
    }
  end

  defp construct(_default, 0), do: %{}

  defp construct(default, size) do
    Enum.into(0..(size - 1), %{}, &{&1, default})
  end

  @behaviour Access

  @impl Access
  def fetch(%MapArray{contents: contents}, index)
      when index >= 0 and index < map_size(contents) do
    Map.fetch(contents, index)
  end

  def fetch(%MapArray{contents: contents}, index)
      when index < 0 and index >= -map_size(contents) do
    Map.fetch(contents, index + map_size(contents))
  end

  def fetch(%MapArray{}, _index), do: :error

  @impl Access
  def get_and_update(array = %MapArray{contents: contents}, index, function)
      when index >= 0 and index < map_size(contents) do
    {value, new_contents} = Map.get_and_update(contents, index, function)
    {value, %MapArray{array | contents: new_contents}}
  end

  @impl Access
  def get_and_update(array = %MapArray{contents: contents}, index, function)
      when index < 0 and index >= -map_size(contents) do
    {value, new_contents} = Map.get_and_update(contents, index, function)
    {value, %MapArray{array | contents: new_contents}}
  end

  def get_and_update(array = %MapArray{}, _index, function) do
    {res, _} = function.(nil)
    {res, array}
  end

  @impl Access
  def pop(array = %MapArray{contents: contents, default: default, length: length}, index)
      when index >= 0 and index < length do
    {value, new_contents} = Map.pop(contents, index, default)

    new_contents =
      for {tindex, value} <- new_contents, into: %{} do
        if tindex <= index, do: {tindex, value}, else: {tindex - 1, value}
      end

    {value, %MapArray{array | contents: new_contents, length: length - 1}}
  end

  def pop(array = %MapArray{contents: contents, default: default, length: length}, index)
      when index < 0 and index >= -length do
    {value, new_contents} = Map.pop(contents, index + length, default)

    new_contents =
      for {tindex, value} <- new_contents, into: %{} do
        if tindex <= index + length, do: {tindex, value}, else: {tindex - 1, value}
      end

    {value, %MapArray{array | contents: new_contents, length: length - 1}}
  end

  defimpl Array.Protocol do
    alias Array.Implementations.MapArray

    @impl true
    def length(%MapArray{length: length}) do
      length
    end

    @impl true
    def fetch(%MapArray{contents: contents, length: length}, index)
        when index >= 0 and index < length do
      contents[index]
    end

    def fetch(%MapArray{contents: contents, length: length}, index)
        when index < 0 and index > -length do
      contents[index + length]
    end

    @impl true
    def replace(array = %MapArray{contents: contents, length: length}, index, value)
        when index >= 0 and index < length do
      new_contents = Map.put(contents, index, value)
      %MapArray{array | contents: new_contents}
    end

    def replace(array = %MapArray{contents: contents, length: length}, index, value)
        when index < 0 and index >= -length do
      new_contents = Map.put(contents, index + length, value)
      %MapArray{array | contents: new_contents}
    end

    @impl true
    def empty(array = %MapArray{contents: contents, default: default}) do
      new_contents = for {index, _value} <- contents, into: %{}, do: {index, default}
      %MapArray{array | contents: new_contents}
    end

    @impl true
    def extract(array = %MapArray{contents: contents, length: length})
        when map_size(contents) > 0 do
      index = length - 1
      elem = contents[index]
      new_contents = Map.delete(contents, index)
      new_array = %MapArray{array | contents: new_contents, length: length - 1}
      {:ok, {elem, new_array}}
    end

    def extract(%MapArray{length: length}) when length == 0 do
      :none
    end

    @impl true
    def iter(array = %MapArray{contents: contents, length: length})
        when map_size(contents) > 0 do
      elem = contents[0]
      new_contents =
        for {index, value} <- Map.delete(contents, 0), into: %{}, do: {index - 1, value}
      new_array = %MapArray{array | contents: new_contents, length: length - 1}
      {:ok, {elem, new_array}}
    end

    def iter(%MapArray{length: length}) when length == 0 do
      :none
    end

    @impl true
    def to_list(%MapArray{contents: contents}) do
      :maps.values(contents)
    end
  end
end
