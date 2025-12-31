// MARK: - Session Types

import Foundation

// MARK: - Type Aliases

/// Unique identifier for a session.
public typealias SessionId = String

/// Unique identifier for a session mode.
public typealias SessionModeId = String

// MARK: - Session Mode

/// Represents an operating mode for the agent.
public struct SessionMode: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional description of the mode.
  public var description: String?

  /// Unique identifier for this mode.
  public var id: SessionModeId

  /// Human-readable name of the mode.
  public var name: String

  public init(
    _meta: Meta = nil,
    description: String? = nil,
    id: SessionModeId,
    name: String
  ) {
    self._meta = _meta
    self.description = description
    self.id = id
    self.name = name
  }
}

// MARK: - Session Mode State

/// The current state of session modes.
public struct SessionModeState: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// List of available modes.
  public var availableModes: [SessionMode]

  /// The ID of the currently active mode.
  public var currentModeId: SessionModeId?

  public init(
    _meta: Meta = nil,
    availableModes: [SessionMode] = [],
    currentModeId: SessionModeId? = nil
  ) {
    self._meta = _meta
    self.availableModes = availableModes
    self.currentModeId = currentModeId
  }
}

// MARK: - Stop Reason

/// The reason why a prompt turn ended.
public enum StopReason: String, Codable, Sendable {
  /// The agent completed its response naturally.
  case endTurn = "end_turn"

  /// The response was cut off due to token limits.
  case maxTokens = "max_tokens"

  /// Maximum number of turn requests reached.
  case maxTurnRequests = "max_turn_requests"

  /// The agent refused to respond.
  case refusal

  /// The operation was cancelled by the client.
  case cancelled
}
