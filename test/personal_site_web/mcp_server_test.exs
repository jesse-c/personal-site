defmodule PersonalSiteWeb.MCPServerTest do
  use ExUnit.Case, async: false

  alias PersonalSiteWeb.MCPServer

  # Note: Using async: false because we're testing a globally named GenServer
  # In production apps, consider using dynamic server names for async testing

  describe "initialize request" do
    test "returns server info and capabilities" do
      response = MCPServer.handle_request("initialize")

      assert response["jsonrpc"] == "2.0"
      assert response["result"]["protocolVersion"] == "2025-03-26"
      assert response["result"]["serverInfo"]["name"] == "Jesse Claven"
      assert response["result"]["serverInfo"]["version"] == "0.1.0"
      assert Map.has_key?(response["result"], "capabilities")
    end
  end

  describe "tools/list request" do
    test "returns available tools" do
      response = MCPServer.handle_request("tools/list")

      assert response["jsonrpc"] == "2.0"
      tools = response["result"]["tools"]
      assert length(tools) == 2

      tool_names = Enum.map(tools, & &1["name"])
      assert "list_blog_posts" in tool_names
      assert "read_blog_post" in tool_names
    end

    test "list_blog_posts tool has correct schema" do
      response = MCPServer.handle_request("tools/list")
      tools = response["result"]["tools"]

      list_tool = Enum.find(tools, &(&1["name"] == "list_blog_posts"))
      assert list_tool["description"] =~ "List all blog posts"

      schema = list_tool["inputSchema"]
      assert schema["type"] == "object"
      assert Map.has_key?(schema["properties"], "limit")
      assert schema["properties"]["limit"]["type"] == "integer"
    end

    test "read_blog_post tool has correct schema" do
      response = MCPServer.handle_request("tools/list")
      tools = response["result"]["tools"]

      read_tool = Enum.find(tools, &(&1["name"] == "read_blog_post"))
      assert read_tool["description"] =~ "Read a specific blog post"

      schema = read_tool["inputSchema"]
      assert schema["type"] == "object"
      assert Map.has_key?(schema["properties"], "slug")
      assert schema["properties"]["slug"]["type"] == "string"
      assert "slug" in schema["required"]
    end
  end

  describe "tools/call request" do
    test "list_blog_posts without limit returns all posts" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "list_blog_posts",
          "arguments" => %{}
        })

      assert response["jsonrpc"] == "2.0"
      result = response["result"]
      assert result["isError"] == false

      content = hd(result["content"])
      assert content["type"] == "text"
      assert String.contains?(content["text"], "Blog Posts:")
    end

    test "list_blog_posts with limit parameter" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "list_blog_posts",
          "arguments" => %{"limit" => 1}
        })

      assert response["jsonrpc"] == "2.0"
      result = response["result"]
      assert result["isError"] == false

      content = hd(result["content"])
      assert content["type"] == "text"
      assert String.contains?(content["text"], "Blog Posts:")
    end

    test "list_blog_posts with zero limit returns error" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "list_blog_posts",
          "arguments" => %{"limit" => 0}
        })

      assert response["jsonrpc"] == "2.0"
      assert response["error"]["code"] == -32_602
      assert response["error"]["message"] == "Limit must be greater than 0"
    end

    test "list_blog_posts with negative limit returns error" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "list_blog_posts",
          "arguments" => %{"limit" => -1}
        })

      assert response["jsonrpc"] == "2.0"
      assert response["error"]["code"] == -32_602
      assert response["error"]["message"] == "Limit must be greater than 0"
    end

    test "read_blog_post with non-existent slug" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "read_blog_post",
          "arguments" => %{"slug" => "non-existent-post"}
        })

      assert response["jsonrpc"] == "2.0"
      assert response["error"]["code"] == -32_602
      assert String.contains?(response["error"]["message"], "not found")
    end

    test "read_blog_post with missing slug parameter" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "read_blog_post",
          "arguments" => %{}
        })

      assert response["jsonrpc"] == "2.0"
      assert response["error"]["code"] == -32_602
      assert response["error"]["message"] == "Missing required parameter: slug"
    end

    test "unknown tool name returns error" do
      response =
        MCPServer.handle_request("tools/call", %{
          "name" => "unknown_tool",
          "arguments" => %{}
        })

      assert response["jsonrpc"] == "2.0"
      assert response["error"]["code"] == -32_602
      assert response["error"]["message"] == "Unknown tool: unknown_tool"
    end
  end

  describe "unknown method" do
    test "returns method not found error" do
      response = MCPServer.handle_request("unknown/method")

      assert response["jsonrpc"] == "2.0"
      assert response["error"]["code"] == -32_601
      assert String.contains?(response["error"]["message"], "Method not found")
    end
  end

  # Integration test to ensure JSON-RPC spec compliance
  describe "JSON-RPC 2.0 compliance" do
    test "all responses include jsonrpc version" do
      methods = ["initialize", "tools/list", "unknown/method"]

      for method <- methods do
        response = MCPServer.handle_request(method)
        assert response["jsonrpc"] == "2.0", "#{method} response missing jsonrpc field"
      end
    end

    test "error responses have proper structure" do
      response = MCPServer.handle_request("unknown/method")

      assert Map.has_key?(response, "error")
      assert Map.has_key?(response["error"], "code")
      assert Map.has_key?(response["error"], "message")
      assert is_integer(response["error"]["code"])
      assert is_binary(response["error"]["message"])
    end
  end
end
