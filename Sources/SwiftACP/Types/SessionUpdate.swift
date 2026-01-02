// MARK: - Session Update Types

import Foundation

// MARK: - Session Update

/// An update notification sent during a prompt turn.
///
/// Session updates are sent via `session/update` notifications to report
/// progress, content, tool calls, and other state changes.
public enum SessionUpdate: Codable, Sendable {
  case userMessageChunk(UserMessageChunk)
  case agentMessageChunk(AgentMessageChunk)
  case agentThoughtChunk(AgentThoughtChunk)
  case toolCall(ToolCallSessionUpdate)
  case toolCallUpdate(ToolCallUpdateSessionUpdate)
  case plan(PlanSessionUpdate)
  case availableCommandsUpdate(AvailableCommandsUpdateSessionUpdate)
  case currentModeUpdate(CurrentModeUpdateSessionUpdate)

  private enum CodingKeys: String, CodingKey {
    case sessionUpdate = "session_update"
  }

  private enum UpdateType: String, Codable {
    case userMessageChunk = "user_message_chunk"
    case agentMessageChunk = "agent_message_chunk"
    case agentThoughtChunk = "agent_thought_chunk"
    case toolCall = "tool_call"
    case toolCallUpdate = "tool_call_update"
    case plan
    case availableCommandsUpdate = "available_commands_update"
    case currentModeUpdate = "current_mode_update"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(UpdateType.self, forKey: .sessionUpdate)

    switch type {
    case .userMessageChunk:
      self = .userMessageChunk(try UserMessageChunk(from: decoder))
    case .agentMessageChunk:
      self = .agentMessageChunk(try AgentMessageChunk(from: decoder))
    case .agentThoughtChunk:
      self = .agentThoughtChunk(try AgentThoughtChunk(from: decoder))
    case .toolCall:
      self = .toolCall(try ToolCallSessionUpdate(from: decoder))
    case .toolCallUpdate:
      self = .toolCallUpdate(try ToolCallUpdateSessionUpdate(from: decoder))
    case .plan:
      self = .plan(try PlanSessionUpdate(from: decoder))
    case .availableCommandsUpdate:
      self = .availableCommandsUpdate(try AvailableCommandsUpdateSessionUpdate(from: decoder))
    case .currentModeUpdate:
      self = .currentModeUpdate(try CurrentModeUpdateSessionUpdate(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .userMessageChunk(let chunk):
      try chunk.encode(to: encoder)
    case .agentMessageChunk(let chunk):
      try chunk.encode(to: encoder)
    case .agentThoughtChunk(let chunk):
      try chunk.encode(to: encoder)
    case .toolCall(let update):
      try update.encode(to: encoder)
    case .toolCallUpdate(let update):
      try update.encode(to: encoder)
    case .plan(let update):
      try update.encode(to: encoder)
    case .availableCommandsUpdate(let update):
      try update.encode(to: encoder)
    case .currentModeUpdate(let update):
      try update.encode(to: encoder)
    }
  }
}

// MARK: - User Message Chunk

/// A chunk of user message content.
public struct UserMessageChunk: Codable, Sendable {
  private var sessionUpdate: String = "user_message_chunk"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The content blocks in this chunk.
  public var content: [ContentBlock]

  public init(_meta: Meta = nil, content: [ContentBlock]) {
    self._meta = _meta
    self.content = content
  }
}

// MARK: - Agent Message Chunk

/// A chunk of agent message content.
public struct AgentMessageChunk: Codable, Sendable {
  private var sessionUpdate: String = "agent_message_chunk"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The content blocks in this chunk.
  public var content: [ContentBlock]

  public init(_meta: Meta = nil, content: [ContentBlock]) {
    self._meta = _meta
    self.content = content
  }
}

// MARK: - Agent Thought Chunk

/// A chunk of agent thinking/reasoning content.
public struct AgentThoughtChunk: Codable, Sendable {
  private var sessionUpdate: String = "agent_thought_chunk"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The content blocks in this chunk.
  public var content: [ContentBlock]

  public init(_meta: Meta = nil, content: [ContentBlock]) {
    self._meta = _meta
    self.content = content
  }
}

// MARK: - Tool Call Session Update

/// A new tool call update.
public struct ToolCallSessionUpdate: Codable, Sendable {
  private var sessionUpdate: String = "tool_call"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Content rendered for this tool call.
  public var content: [ToolCallContent]?

  /// The kind of tool being called.
  public var kind: ToolKind?

  /// Locations in files affected by this tool call.
  public var locations: [ToolCallLocation]?

  /// The raw input to the tool (arbitrary JSON).
  public var rawInput: AnyCodable?

  /// The raw output from the tool (arbitrary JSON).
  public var rawOutput: AnyCodable?

  /// The current status of the tool call.
  public var status: ToolCallStatus

  /// Human-readable title for the tool call.
  public var title: String?

  /// Unique identifier for this tool call.
  public var toolCallId: ToolCallId

  public init(
    _meta: Meta = nil,
    content: [ToolCallContent]? = nil,
    kind: ToolKind? = nil,
    locations: [ToolCallLocation]? = nil,
    rawInput: AnyCodable? = nil,
    rawOutput: AnyCodable? = nil,
    status: ToolCallStatus,
    title: String? = nil,
    toolCallId: ToolCallId
  ) {
    self._meta = _meta
    self.content = content
    self.kind = kind
    self.locations = locations
    self.rawInput = rawInput
    self.rawOutput = rawOutput
    self.status = status
    self.title = title
    self.toolCallId = toolCallId
  }
}

// MARK: - Tool Call Update Session Update

/// An update to an existing tool call.
public struct ToolCallUpdateSessionUpdate: Codable, Sendable {
  private var sessionUpdate: String = "tool_call_update"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Updated content for this tool call.
  public var content: [ToolCallContent]?

  /// Updated kind of tool.
  public var kind: ToolKind?

  /// Updated locations.
  public var locations: [ToolCallLocation]?

  /// Updated raw input (arbitrary JSON).
  public var rawInput: AnyCodable?

  /// Updated raw output (arbitrary JSON).
  public var rawOutput: AnyCodable?

  /// Updated status.
  public var status: ToolCallStatus?

  /// Updated title.
  public var title: String?

  /// The ID of the tool call being updated.
  public var toolCallId: ToolCallId

  public init(
    _meta: Meta = nil,
    content: [ToolCallContent]? = nil,
    kind: ToolKind? = nil,
    locations: [ToolCallLocation]? = nil,
    rawInput: AnyCodable? = nil,
    rawOutput: AnyCodable? = nil,
    status: ToolCallStatus? = nil,
    title: String? = nil,
    toolCallId: ToolCallId
  ) {
    self._meta = _meta
    self.content = content
    self.kind = kind
    self.locations = locations
    self.rawInput = rawInput
    self.rawOutput = rawOutput
    self.status = status
    self.title = title
    self.toolCallId = toolCallId
  }
}

// MARK: - Plan Session Update

/// A plan update.
public struct PlanSessionUpdate: Codable, Sendable {
  private var sessionUpdate: String = "plan"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The plan entries.
  public var entries: [PlanEntry]

  public init(_meta: Meta = nil, entries: [PlanEntry]) {
    self._meta = _meta
    self.entries = entries
  }
}

// MARK: - Available Commands Update Session Update

/// An update to the available commands.
public struct AvailableCommandsUpdateSessionUpdate: Codable, Sendable {
  private var sessionUpdate: String = "available_commands_update"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The available commands.
  public var availableCommands: [AvailableCommand]

  public init(_meta: Meta = nil, availableCommands: [AvailableCommand]) {
    self._meta = _meta
    self.availableCommands = availableCommands
  }
}

// MARK: - Current Mode Update Session Update

/// An update to the current session mode.
public struct CurrentModeUpdateSessionUpdate: Codable, Sendable {
  private var sessionUpdate: String = "current_mode_update"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the new current mode.
  public var currentModeId: SessionModeId

  public init(_meta: Meta = nil, currentModeId: SessionModeId) {
    self._meta = _meta
    self.currentModeId = currentModeId
  }
}

// MARK: - Current Mode Update

/// An update indicating the current mode has changed.
public struct CurrentModeUpdate: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the current mode.
  public var currentModeId: SessionModeId

  public init(_meta: Meta = nil, currentModeId: SessionModeId) {
    self._meta = _meta
    self.currentModeId = currentModeId
  }
}

// MARK: - Available Commands Update

/// An update with new available commands.
public struct AvailableCommandsUpdate: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Commands the agent can execute.
  public var availableCommands: [AvailableCommand]

  public init(_meta: Meta = nil, availableCommands: [AvailableCommand]) {
    self._meta = _meta
    self.availableCommands = availableCommands
  }
}

// MARK: - Available Command

/// Information about a slash command.
public struct AvailableCommand: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Human-readable description of what the command does.
  public var description: String

  /// Input specification for the command if required.
  public var input: AvailableCommandInput?

  /// Command name (e.g., `create_plan`, `research_codebase`).
  public var name: String

  public init(
    _meta: Meta = nil,
    description: String,
    input: AvailableCommandInput? = nil,
    name: String
  ) {
    self._meta = _meta
    self.description = description
    self.input = input
    self.name = name
  }
}

// MARK: - Available Command Input

/// The input specification for a command.
public enum AvailableCommandInput: Codable, Sendable {
  case unstructured(UnstructuredCommandInput)

  public init(from decoder: Decoder) throws {
    self = .unstructured(try UnstructuredCommandInput(from: decoder))
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .unstructured(let input):
      try input.encode(to: encoder)
    }
  }
}

// MARK: - Unstructured Command Input

/// Unstructured text input for a command.
public struct UnstructuredCommandInput: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// A hint for the input placeholder text.
  public var hint: String?

  public init(_meta: Meta = nil, hint: String? = nil) {
    self._meta = _meta
    self.hint = hint
  }
}
