defmodule PersonalSiteWeb.MCPController do
  use PersonalSiteWeb, :controller

  alias PersonalSiteWeb.MCPErrors
  alias PersonalSiteWeb.MCPServer

  def handle_request(conn, _params) do
    wants_stream = wants_streaming?(conn)
    {raw_body, parsed_data} = extract_request_data(conn)

    process_mcp_request(conn, raw_body, parsed_data, wants_stream)
  end

  defp wants_streaming?(conn) do
    accept_header = get_req_header(conn, "accept") |> List.first() || ""
    String.starts_with?(accept_header, "text/event-stream")
  end

  defp extract_request_data(conn) do
    case conn.body_params do
      %Plug.Conn.Unfetched{} ->
        case Plug.Conn.read_body(conn) do
          {:ok, body, _conn} -> {body, nil}
          {:error, _} -> {"", nil}
        end

      %{"_json" => json_array} when is_list(json_array) ->
        {"", json_array}

      body_params ->
        case Jason.encode(body_params) do
          {:ok, json} -> {json, nil}
          {:error, _} -> {"", nil}
        end
    end
  end

  defp process_mcp_request(conn, raw_body, parsed_data, wants_stream) do
    cond do
      is_list(parsed_data) ->
        handle_batch_requests(conn, parsed_data, wants_stream)

      raw_body != "" ->
        handle_raw_json(conn, raw_body, wants_stream)

      true ->
        send_parse_error(conn, "No valid JSON data found")
    end
  end

  defp handle_raw_json(conn, raw_body, wants_stream) do
    case Jason.decode(raw_body) do
      {:ok, requests} when is_list(requests) ->
        handle_batch_requests(conn, requests, wants_stream)

      {:ok, %{"method" => _method} = request} ->
        handle_single_request(conn, request, wants_stream)

      {:ok, %{"result" => _}} ->
        conn |> put_status(202) |> json(%{})

      {:error, decode_error} ->
        send_parse_error(conn, "Parse error: #{inspect(decode_error)}")
    end
  end

  defp send_parse_error(conn, message) do
    conn
    |> put_status(400)
    |> json(%{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => MCPErrors.parse_error(),
        "message" => message
      }
    })
  end

  # Handle GET requests - can return info or open SSE stream (Streamable HTTP spec)
  def get_info(conn, _params) do
    # Check Accept header to determine response format
    accept_header = get_req_header(conn, "accept") |> List.first() || ""
    wants_stream = String.starts_with?(accept_header, "text/event-stream")

    # Handle session ID if provided
    session_id = get_req_header(conn, "mcp-session-id") |> List.first()

    if wants_stream do
      # Open SSE stream for GET requests (new in streamable HTTP spec)
      send_sse_stream_for_get(conn, session_id)
    else
      # Return server metadata (traditional behavior)
      conn
      |> json(%{
        "transport" => "streamable-http",
        "version" => "2025-03-26",
        "capabilities" => %{
          "tools" => %{},
          "streaming" => true,
          "sessions" => session_id != nil
        }
      })
    end
  end

  defp handle_single_request(conn, request, wants_stream) do
    method = Map.get(request, "method")
    request_params = Map.get(request, "params", %{})
    id = Map.get(request, "id")

    response = MCPServer.handle_request(method, request_params)
    response = if id, do: Map.put(response, "id", id), else: response

    if wants_stream do
      send_streamed_response(conn, [response])
    else
      conn
      |> put_resp_content_type("application/json")
      |> json(response)
    end
  end

  defp handle_batch_requests(conn, requests, wants_stream) do
    responses =
      requests
      |> Enum.map(fn request ->
        method = Map.get(request, "method")
        request_params = Map.get(request, "params", %{})
        id = Map.get(request, "id")

        response = MCPServer.handle_request(method, request_params)
        if id, do: Map.put(response, "id", id), else: response
      end)

    if wants_stream do
      send_streamed_response(conn, responses)
    else
      conn
      |> put_resp_content_type("application/json")
      |> json(responses)
    end
  end

  defp send_streamed_response(conn, responses) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    # Send each response as SSE data
    conn =
      Enum.reduce(responses, conn, fn response, acc_conn ->
        json_data = Jason.encode!(response)
        chunk_data = "data: #{json_data}\n\n"
        {:ok, new_conn} = chunk(acc_conn, chunk_data)
        new_conn
      end)

    # Close the stream naturally without sending termination marker
    # Some streaming APIs send "data: [DONE]\n\n" to signal end of stream,
    # but MCP spec doesn't require this, so we just return the connection
    # and let Phoenix close it when the response completes
    conn
  end

  # Handle GET request SSE streams (new in streamable HTTP spec)
  defp send_sse_stream_for_get(conn, session_id) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    # Send server notifications or keep alive (implementation specific)
    # For now, just send a connection established notification
    notification = %{
      "jsonrpc" => "2.0",
      "method" => "notifications/resources/updated",
      "params" => %{
        "uri" => "mcp://server/session",
        "message" => "Session established",
        "sessionId" => session_id
      }
    }

    json_data = Jason.encode!(notification)
    chunk_data = "data: #{json_data}\n\n"
    {:ok, conn} = chunk(conn, chunk_data)

    # Keep connection open for real streaming scenarios
    conn
  end

  # Handle DELETE requests for session termination (MCP spec requirement)
  def terminate_session(conn, _params) do
    # Get session ID from header
    session_id = get_req_header(conn, "mcp-session-id") |> List.first()

    if session_id do
      # Terminate the session (implementation specific)
      # For now, just return 200 OK to indicate successful termination
      send_resp(conn, 200, "")
    else
      # No session ID provided, return 400 Bad Request
      conn
      |> put_status(400)
      |> json(%{"error" => "Missing Mcp-Session-Id header"})
    end
  end
end
