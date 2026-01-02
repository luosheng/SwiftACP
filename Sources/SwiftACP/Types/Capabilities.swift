// MARK: - Capabilities

import Foundation

// MARK: - Agent Capabilities

/// Capabilities supported by the agent.
///
/// Advertised during initialization to inform the client about
/// available features and content types.
public struct AgentCapabilities: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Whether the agent supports `session/load`.
  public var loadSession: Bool

  /// MCP capabilities supported by the agent.
  public var mcpCapabilities: McpCapabilities?

  /// Prompt capabilities supported by the agent.
  public var promptCapabilities: PromptCapabilities?

  /// Session capabilities.
  public var sessionCapabilities: SessionCapabilities?

  public init(
    _meta: Meta = nil,
    loadSession: Bool = false,
    mcpCapabilities: McpCapabilities? = nil,
    promptCapabilities: PromptCapabilities? = nil,
    sessionCapabilities: SessionCapabilities? = nil
  ) {
    self._meta = _meta
    self.loadSession = loadSession
    self.mcpCapabilities = mcpCapabilities
    self.promptCapabilities = promptCapabilities
    self.sessionCapabilities = sessionCapabilities
  }
}

// MARK: - Client Capabilities

/// Capabilities supported by the client.
///
/// Advertised during initialization to inform the agent about
/// available features and methods.
public struct ClientCapabilities: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// File system capabilities supported by the client.
  public var fs: FileSystemCapability

  /// Whether the Client supports all `terminal/*` methods.
  public var terminal: Bool

  public init(
    _meta: Meta = nil,
    fs: FileSystemCapability = FileSystemCapability(),
    terminal: Bool = false
  ) {
    self._meta = _meta
    self.fs = fs
    self.terminal = terminal
  }
}

// MARK: - File System Capability

/// File system capabilities for reading and writing files.
public struct FileSystemCapability: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Whether `fs/read_text_file` is supported.
  public var readTextFile: Bool

  /// Whether `fs/write_text_file` is supported.
  public var writeTextFile: Bool

  public init(
    _meta: Meta = nil,
    readTextFile: Bool = false,
    writeTextFile: Bool = false
  ) {
    self._meta = _meta
    self.readTextFile = readTextFile
    self.writeTextFile = writeTextFile
  }
}

// MARK: - MCP Capabilities

/// Model Context Protocol capabilities.
public struct McpCapabilities: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Whether `McpServer::Http` is supported.
  public var http: Bool

  /// Whether `McpServer::Sse` is supported.
  public var sse: Bool

  public init(
    _meta: Meta = nil,
    http: Bool = false,
    sse: Bool = false
  ) {
    self._meta = _meta
    self.http = http
    self.sse = sse
  }
}

// MARK: - Prompt Capabilities

/// Capabilities for content types supported in prompts.
public struct PromptCapabilities: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Whether `ContentBlock::Audio` is supported.
  public var audio: Bool

  /// Whether embedded context resources are supported in `session/prompt`.
  public var embeddedContext: Bool

  /// Whether `ContentBlock::Image` is supported.
  public var image: Bool

  public init(
    _meta: Meta = nil,
    audio: Bool = false,
    embeddedContext: Bool = false,
    image: Bool = false
  ) {
    self._meta = _meta
    self.audio = audio
    self.embeddedContext = embeddedContext
    self.image = image
  }
}

// MARK: - Session Capabilities

/// Session-related capabilities.
///
/// This type is currently extensible through `_meta` only.
public struct SessionCapabilities: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  public init(_meta: Meta = nil) {
    self._meta = _meta
  }
}
