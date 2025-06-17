defmodule PersonalSiteWeb.MCPServer do
  @moduledoc """
  MCP (Model Context Protocol) Server implementation for Personal Site blog.

  Provides tools for:
  - list_blog_posts: List all blog posts with metadata
  - read_blog_post: Read a specific blog post by slug
  """

  use GenServer
  require Logger

  alias PersonalSite.Blog
  alias PersonalSiteWeb.MCPErrors

  @server_info %{
    "name" => "Jesse Claven",
    "version" => "0.1.0",
    "protocolVersion" => "2025-03-26",
    "capabilities" => %{
      "tools" => %{}
    }
  }

  @tools [
    %{
      "name" => "list_blog_posts",
      "description" => "List all blog posts with their metadata (title, slug, date, tags)",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "limit" => %{
            "type" => "integer",
            "description" => "Maximum number of posts to return (optional)",
            "minimum" => 1
          }
        },
        "additionalProperties" => false
      }
    },
    %{
      "name" => "read_blog_post",
      "description" => "Read a specific blog post by its slug",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "slug" => %{
            "type" => "string",
            "description" => "The slug identifier of the blog post"
          }
        },
        "required" => ["slug"],
        "additionalProperties" => false
      }
    }
  ]

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(_opts) do
    Logger.info("MCP Server started for Personal Site Blog")
    {:ok, %{}}
  end

  def handle_request(method, params \\ %{}, server \\ __MODULE__),
    do: GenServer.call(server, {:handle_request, method, params})

  @impl true
  def handle_call({:handle_request, method, params}, _from, state) do
    response = process_request(method, params)
    {:reply, response, state}
  end

  defp process_request(method, params)

  defp process_request("initialize", _params) do
    success_response(%{
      "protocolVersion" => @server_info["protocolVersion"],
      "capabilities" => @server_info["capabilities"],
      "serverInfo" => @server_info
    })
  end

  defp process_request("tools/list", _params), do: success_response(%{"tools" => @tools})

  defp process_request("tools/call", %{"name" => tool_name, "arguments" => args}) do
    case execute_tool(tool_name, args) do
      {:ok, result} -> success_response(result)
      {:error, message} -> error_response(MCPErrors.invalid_params(), message)
    end
  end

  defp process_request(method, _params),
    do: error_response(MCPErrors.method_not_found(), "Method not found: #{method}")

  defp execute_tool("list_blog_posts", args) do
    limit = Map.get(args, "limit")

    Blog.all_posts()
    |> maybe_limit_posts(limit)
    |> case do
      {:ok, posts} ->
        formatted_posts = Enum.map(posts, &format_post_summary/1)

        content = [
          %{
            "type" => "text",
            "text" => "Blog Posts:\n\n" <> format_posts_list(formatted_posts)
          }
        ]

        {:ok, %{"content" => content, "isError" => false}}

      {:error, message} ->
        {:error, message}
    end
  end

  defp execute_tool("read_blog_post", %{"slug" => slug}) do
    post = Blog.get_post_by_slug!(slug)

    content = [
      %{
        "type" => "text",
        "text" => format_full_post(post)
      }
    ]

    {:ok, %{"content" => content, "isError" => false}}
  rescue
    Blog.NotFoundError ->
      {:error, "Blog post with slug '#{slug}' not found"}
  end

  defp execute_tool("read_blog_post", _args), do: {:error, "Missing required parameter: slug"}

  defp execute_tool(tool_name, _args), do: {:error, "Unknown tool: #{tool_name}"}

  defp maybe_limit_posts(posts, limit)
  defp maybe_limit_posts(posts, nil), do: {:ok, posts}

  defp maybe_limit_posts(posts, limit) when is_integer(limit) and limit > 0,
    do: {:ok, Enum.take(posts, limit)}

  defp maybe_limit_posts(_posts, limit) when is_integer(limit) and limit <= 0,
    do: {:error, "Limit must be greater than 0"}

  defp maybe_limit_posts(_posts, _), do: {:error, "Limit must be an integer"}

  defp format_post_summary(post),
    do: %{
      "title" => post.title,
      "slug" => post.slug,
      "date_created" => Date.to_string(post.date_created),
      "date_updated" => if(post.date_updated, do: Date.to_string(post.date_updated)),
      "tags" => post.tags
    }

  defp format_posts_list(posts) do
    Enum.map_join(posts, "\n", fn post ->
      updated = if post["date_updated"], do: " (updated: #{post["date_updated"]})", else: ""
      tags = if Enum.any?(post["tags"]), do: " | Tags: #{Enum.join(post["tags"], ", ")}", else: ""
      "- **#{post["title"]}** (#{post["slug"]}) - #{post["date_created"]}#{updated}#{tags}"
    end)
  end

  defp format_full_post(post) do
    updated =
      if post.date_updated, do: " (updated: #{Date.to_string(post.date_updated)})", else: ""

    tags = if Enum.any?(post.tags), do: "\n**Tags:** #{Enum.join(post.tags, ", ")}", else: ""

    """
    # #{post.title}

    **Published:** #{Date.to_string(post.date_created)}#{updated}#{tags}
    **Slug:** #{post.slug}

    ---

    #{post.body}
    """
  end

  defp success_response(result),
    do: %{
      "jsonrpc" => "2.0",
      "result" => result
    }

  defp error_response(code, message),
    do: %{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => code,
        "message" => message
      }
    }
end
