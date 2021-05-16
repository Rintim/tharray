
defmodule Array.Behaviour do
  @type option :: {:default, any} | {atom, any}
  @type options :: [option]
  @callback new(options) :: Arrays.Protocol.t()
  @callback new(Enumerable.acc(), options) :: Arrays.Protocol.t()
end
