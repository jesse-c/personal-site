defmodule PersonalSite.Redis do
  @name :redis

  def name, do: @name

  def command(command), do: Redix.command(@name, command)
end