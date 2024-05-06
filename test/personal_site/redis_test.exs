defmodule PersonalSite.RedisTest do
  use ExUnit.Case

  alias PersonalSite.Redis

  describe "name/0" do
    test "returns the configured Redis name" do
      assert Redis.name() == :redis
    end
  end

  describe "command/1" do
    test "passes the command to the default Redis instance" do
      command = ["SET", "X", "1"]

      assert Redis.command(command) == {:ok, "OK"}
    end
  end
end
