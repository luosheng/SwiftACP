// MARK: - Agent Methods (Client → Agent)

import Foundation

// MARK: - Initialize

/// Request parameters for the initialize method.
///
/// Negotiate the protocol version to use and exchange capability information.
public struct InitializeRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Capabilities supported by the client.
  public var clientCapabilities: ClientCapabilities

  /// Information about the client implementation.
  public var clientInfo: Implementation

  /// The protocol version the client supports.
  public var protocolVersion: ProtocolVersion

  public init(
    _meta: Meta = nil,
    clientCapabilities: ClientCapabilities = ClientCapabilities(),
    clientInfo: Implementation,
    protocolVersion: ProtocolVersion
  ) {
    self._meta = _meta
    self.clientCapabilities = clientCapabilities
    self.clientInfo = clientInfo
    self.protocolVersion = protocolVersion
  }
}

/// Response to the initialize method.
public struct InitializeResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Capabilities supported by the agent.
  public var agentCapabilities: AgentCapabilities

  /// Information about the agent implementation.
  public var agentInfo: Implementation

  /// Available authentication methods.
  public var authMethods: [AuthMethod]

  /// The negotiated protocol version.
  public var protocolVersion: ProtocolVersion

  public init(
    _meta: Meta = nil,
    agentCapabilities: AgentCapabilities = AgentCapabilities(),
    agentInfo: Implementation,
    authMethods: [AuthMethod] = [],
    protocolVersion: ProtocolVersion
  ) {
    self._meta = _meta
    self.agentCapabilities = agentCapabilities
    self.agentInfo = agentInfo
    self.authMethods = authMethods
    self.protocolVersion = protocolVersion
  }
}

// MARK: - Authenticate

/// Request parameters for the authenticate method.
public struct AuthenticateRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the authentication method to use.
  public var methodId: String

  public init(_meta: Meta = nil, methodId: String) {
    self._meta = _meta
    self.methodId = methodId
  }
}

/// Response to the authenticate method.
public struct AuthenticateResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  public init(_meta: Meta = nil) {
    self._meta = _meta
  }
}

// MARK: - Session New

/// Request parameters for the session/new method.
public struct NewSessionRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The working directory for the session.
  public var cwd: String?

  /// MCP servers to connect to.
  public var mcpServers: [McpServer]?

  public init(
    _meta: Meta = nil,
    cwd: String? = nil,
    mcpServers: [McpServer]? = nil
  ) {
    self._meta = _meta
    self.cwd = cwd
    self.mcpServers = mcpServers
  }
}

/// Response to the session/new method.
public struct NewSessionResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Available session modes.
  public var modes: SessionModeState?

  /// The unique ID for the new session.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    modes: SessionModeState? = nil,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.modes = modes
    self.sessionId = sessionId
  }
}

// MARK: - Session Load

/// Request parameters for the session/load method.
public struct LoadSessionRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The working directory for the session.
  public var cwd: String?

  /// MCP servers to connect to.
  public var mcpServers: [McpServer]?

  /// The ID of the session to load.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    cwd: String? = nil,
    mcpServers: [McpServer]? = nil,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.cwd = cwd
    self.mcpServers = mcpServers
    self.sessionId = sessionId
  }
}

/// Response to the session/load method.
public struct LoadSessionResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Available session modes.
  public var modes: SessionModeState?

  public init(
    _meta: Meta = nil,
    modes: SessionModeState? = nil
  ) {
    self._meta = _meta
    self.modes = modes
  }
}

// MARK: - Session Prompt

/// Request parameters for the session/prompt method.
public struct PromptRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The prompt content blocks.
  public var prompt: [ContentBlock]

  /// The ID of the session.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    prompt: [ContentBlock],
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.prompt = prompt
    self.sessionId = sessionId
  }
}

/// Response to the session/prompt method.
public struct PromptResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The reason the prompt turn ended.
  public var stopReason: StopReason

  public init(_meta: Meta = nil, stopReason: StopReason) {
    self._meta = _meta
    self.stopReason = stopReason
  }
}

// MARK: - Session Set Mode

/// Request parameters for the session/set_mode method.
public struct SetSessionModeRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the mode to switch to.
  public var modeId: SessionModeId

  /// The ID of the session.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    modeId: SessionModeId,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.modeId = modeId
    self.sessionId = sessionId
  }
}

/// Response to the session/set_mode method.
public struct SetSessionModeResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  public init(_meta: Meta = nil) {
    self._meta = _meta
  }
}

// MARK: - Session Cancel

/// Notification to cancel ongoing operations for a session.
public struct CancelNotification: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the session to cancel operations for.
  public var sessionId: SessionId

  public init(_meta: Meta = nil, sessionId: SessionId) {
    self._meta = _meta
    self.sessionId = sessionId
  }
}

// MARK: - Method Names

/// Method names for agent-side methods.
public enum AgentMethod: String, Sendable {
  case initialize
  case authenticate
  case sessionNew = "session/new"
  case sessionLoad = "session/load"
  case sessionPrompt = "session/prompt"
  case sessionSetMode = "session/set_mode"
  case sessionCancel = "session/cancel"
}
