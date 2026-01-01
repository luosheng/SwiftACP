// MARK: - ACP Client Errors

import Foundation

/// Errors that can occur during ACP client operations.
public enum ACPClientError: Error, Sendable {
  /// The client is not connected to the transport.
  case notConnected

  /// Failed to connect to the agent.
  case connectionFailed(String)

  /// A request timed out waiting for a response.
  case requestTimeout(RequestId)

  /// Failed to decode a response from the agent.
  case decodingFailed(String)

  /// Failed to encode a request to send to the agent.
  case encodingFailed(String)

  /// The agent returned a JSON-RPC error.
  case rpcError(JSONRPCError)

  /// Received an unexpected response format.
  case unexpectedResponse

  /// A delegate method was required but no delegate is set.
  case delegateNotSet

  /// The transport was closed unexpectedly.
  case transportClosed
}
