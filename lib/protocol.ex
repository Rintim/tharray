
defprotocol Array.Protocol do
  @type array :: t
  @type index :: integer
  @type value :: any

  @spec length(array) :: non_neg_integer
  def length(array)

  @spec fetch(array, index) :: {:ok, value} | nil
  def fetch(array, index)

  @spec replace(array, index, item :: any) :: array
  def replace(array, index, item)

  @spec extract(array) :: {:ok, {item :: any, array}} | :none
  def extract(array)

  @spec iter(array) :: {:ok, {item :: any, array}} | :none
  def iter(array)

  @spec empty(array) :: array
  def empty(array)

  @spec to_list(array) :: list
  def to_list(array)
end
