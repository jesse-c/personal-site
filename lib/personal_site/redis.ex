defmodule PersonalSite.Redis do
  @name :redis

  def name, do: @name

  @doc """
  Pass through command to default Redis instance
  """
  def command(command), do: Redix.command(@name, command)
end
