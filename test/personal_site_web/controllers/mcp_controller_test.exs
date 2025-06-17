defmodule PersonalSiteWeb.MCPControllerTest do
  use PersonalSiteWeb.ConnCase, async: true

  # Setup helper for JSON requests
  defp json_conn(conn) do
    conn |> put_req_header("content-type", "application/json")
  end

  describe "handle_request/2" do
    test "handles single JSON-RPC request", %{conn: conn} do
      request = %{"jsonrpc" => "2.0", "method" => "initialize", "id" => 1}

      conn =
        conn
        |> json_conn()
        |> post("/mcp", request)

      assert conn.status == 200
      response = json_response(conn, 200)
      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 1
      assert Map.has_key?(response, "result")
    end

    test "handles tools/list request", %{conn: conn} do
      request = %{"jsonrpc" => "2.0", "method" => "tools/list", "id" => 2}

      conn =
        conn
        |> json_conn()
        |> post("/mcp", request)

      assert conn.status == 200
      response = json_response(conn, 200)
      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 2
      assert Map.has_key?(response["result"], "tools")
      assert length(response["result"]["tools"]) == 2
    end

    test "handles tools/call request", %{conn: conn} do
      request = %{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "params" => %{
          "name" => "list_blog_posts",
          "arguments" => %{}
        },
        "id" => 3
      }

      conn =
        conn
        |> json_conn()
        |> post("/mcp", request)

      assert conn.status == 200
      response = json_response(conn, 200)
      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 3
      assert Map.has_key?(response, "result")
    end

    test "accepts client response (202 Accepted)", %{conn: conn} do
      response = %{"jsonrpc" => "2.0", "result" => %{"status" => "ok"}, "id" => 1}

      conn =
        conn
        |> json_conn()
        |> post("/mcp", response)

      assert conn.status == 202
      assert json_response(conn, 202) == %{}
    end
  end

  describe "get_info/2" do
    test "returns server metadata by default", %{conn: conn} do
      conn =
        conn
        |> json_conn()
        |> get("/mcp")

      assert conn.status == 200
      response = json_response(conn, 200)
      assert response["transport"] == "streamable-http"
      assert response["version"] == "2025-03-26"
      assert Map.has_key?(response, "capabilities")
    end

    test "handles requests with session ID header", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> put_req_header("mcp-session-id", "test-session-123")
        |> get("/mcp")

      assert conn.status == 200
      response = json_response(conn, 200)
      assert response["capabilities"]["sessions"] == true
    end
  end

  describe "terminate_session/2" do
    test "terminates session with valid session ID", %{conn: conn} do
      conn =
        conn
        |> put_req_header("mcp-session-id", "test-session-123")
        |> delete("/mcp")

      assert conn.status == 200
      # No CORS headers expected since we removed them
    end

    test "returns 400 when session ID is missing", %{conn: conn} do
      conn = delete(conn, "/mcp")

      assert conn.status == 400
      response = json_response(conn, 400)
      assert response["error"] == "Missing Mcp-Session-Id header"
    end

    test "no longer validates origin header", %{conn: conn} do
      conn =
        conn
        |> put_req_header("origin", "https://evil.com")
        |> put_req_header("mcp-session-id", "test-session-123")
        |> delete("/mcp")

      # Origin validation was removed, so this should succeed
      assert conn.status == 200
    end
  end
end
