defmodule Identicon.Application do
  use Application

  def start(_type, _args) do
    Identicon.main()
    {:ok, self()}
  end
end
