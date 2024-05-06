defmodule PersonalSite.Redis do
  @moduledoc """
  A Redis wrapper.
  """

  @name :redis

  def name, do: @name

  @doc """
  Pass through command to default Redis instance
  """
  def command(command), do: Redix.command(@name, command)
end
