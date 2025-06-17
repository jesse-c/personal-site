defmodule PersonalSiteWeb.MCPErrors do
  @moduledoc """
  JSON-RPC 2.0 Error Codes for MCP
  """

  # JSON-RPC 2.0 Error Codes
  @json_rpc_parse_error -32_700
  @json_rpc_invalid_request -32_600
  @json_rpc_method_not_found -32_601
  @json_rpc_invalid_params -32_602
  @json_rpc_internal_error -32_603

  def parse_error, do: @json_rpc_parse_error
  def invalid_request, do: @json_rpc_invalid_request
  def method_not_found, do: @json_rpc_method_not_found
  def invalid_params, do: @json_rpc_invalid_params
  def internal_error, do: @json_rpc_internal_error
end
