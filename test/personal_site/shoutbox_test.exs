defmodule PersonalSite.ShoutboxTest do
  use ExUnit.Case, async: true

  alias PersonalSite.Shoutbox

  setup do
    # Clear the shoutbox before each test
    Shoutbox.clear()

    :ok
  end

  test "new/3 adds a new shout" do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    assert :ok = Shoutbox.new("John", timestamp, "Hello, world!")
    assert [%{name: "John", timestamp: ^timestamp, message: "Hello, world!"}] = Shoutbox.list()
  end

  test "new/3 adds multiple new shouts which trims" do
    timestamp1 = DateTime.utc_now() |> DateTime.to_iso8601()
    timestamp2 = DateTime.utc_now() |> DateTime.to_iso8601()
    timestamp3 = DateTime.utc_now() |> DateTime.to_iso8601()

    Shoutbox.new("Alice", timestamp1, "First shout")
    Shoutbox.new("Bob", timestamp2, "Second shout")
    Shoutbox.new("Bill", timestamp3, "Third shout")

    assert [
             %{name: "Bill", timestamp: _, message: "Third shout"},
             %{name: "Bob", timestamp: _, message: "Second shout"}
           ] = Shoutbox.list()
  end

  test "list/0 returns all current shouts" do
    timestamp1 = DateTime.utc_now() |> DateTime.to_iso8601()
    timestamp2 = DateTime.utc_now() |> DateTime.to_iso8601()

    Shoutbox.new("Alice", timestamp1, "First shout")
    Shoutbox.new("Bob", timestamp2, "Second shout")

    assert [
             %{name: "Bob", timestamp: _, message: "Second shout"},
             %{name: "Alice", timestamp: _, message: "First shout"}
           ] = Shoutbox.list()
  end

  test "clear/0 removes all current shouts" do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    Shoutbox.new("John", timestamp, "Hello, world!")
    assert :ok = Shoutbox.clear()
  end
end
