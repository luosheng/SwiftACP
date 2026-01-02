// MARK: - MCP Server Types

import Foundation

// MARK: - MCP Server

/// Configuration for a Model Context Protocol server.
public enum McpServer: Codable, Sendable {
  case http(McpServerHttp)
  case sse(McpServerSse)
  case stdio(McpServerStdio)

  private enum CodingKeys: String, CodingKey {
    case type
  }

  private enum ServerType: String, Codable {
    case http
    case sse
    case stdio
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ServerType.self, forKey: .type)

    switch type {
    case .http:
      self = .http(try McpServerHttp(from: decoder))
    case .sse:
      self = .sse(try McpServerSse(from: decoder))
    case .stdio:
      self = .stdio(try McpServerStdio(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .http(let server):
      try server.encode(to: encoder)
    case .sse(let server):
      try server.encode(to: encoder)
    case .stdio(let server):
      try server.encode(to: encoder)
    }
  }
}

// MARK: - MCP Server HTTP

/// HTTP-based MCP server configuration.
public struct McpServerHttp: Codable, Sendable {
  private var type: String = "http"

  /// Extensible metadata field.
  public var _meta: Meta

  /// HTTP headers to include in requests.
  public var headers: [HttpHeader]?

  /// Name of the MCP server.
  public var name: String

  /// URL of the MCP server.
  public var url: String

  public init(
    _meta: Meta = nil,
    headers: [HttpHeader]? = nil,
    name: String,
    url: String
  ) {
    self._meta = _meta
    self.headers = headers
    self.name = name
    self.url = url
  }
}

// MARK: - MCP Server SSE

/// Server-Sent Events based MCP server configuration.
public struct McpServerSse: Codable, Sendable {
  private var type: String = "sse"

  /// Extensible metadata field.
  public var _meta: Meta

  /// HTTP headers to include in requests.
  public var headers: [HttpHeader]?

  /// Name of the MCP server.
  public var name: String

  /// URL of the MCP server.
  public var url: String

  public init(
    _meta: Meta = nil,
    headers: [HttpHeader]? = nil,
    name: String,
    url: String
  ) {
    self._meta = _meta
    self.headers = headers
    self.name = name
    self.url = url
  }
}

// MARK: - MCP Server Stdio

/// Standard I/O based MCP server configuration.
public struct McpServerStdio: Codable, Sendable {
  private var type: String = "stdio"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Arguments to pass to the command.
  public var args: [String]?

  /// The command to execute.
  public var command: String

  /// Environment variables for the command.
  public var env: [EnvVariable]?

  /// Name of the MCP server.
  public var name: String

  public init(
    _meta: Meta = nil,
    args: [String]? = nil,
    command: String,
    env: [EnvVariable]? = nil,
    name: String
  ) {
    self._meta = _meta
    self.args = args
    self.command = command
    self.env = env
    self.name = name
  }
}

// MARK: - HTTP Header

/// An HTTP header.
public struct HttpHeader: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The header name.
  public var name: String

  /// The header value.
  public var value: String

  public init(_meta: Meta = nil, name: String, value: String) {
    self._meta = _meta
    self.name = name
    self.value = value
  }
}
