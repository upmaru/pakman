defmodule Pakman.System.Behaviour do
  @callback cmd(binary, list(binary)) :: any
end

Mox.defmock(Pakman.SystemMock, for: Pakman.System.Behaviour)
