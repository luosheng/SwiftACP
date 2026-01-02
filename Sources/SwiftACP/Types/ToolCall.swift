// MARK: - Tool Call Types

import Foundation

// MARK: - Type Aliases

/// Unique identifier for a tool call.
public typealias ToolCallId = String

// MARK: - Tool Call

/// Represents a tool invocation by the agent.
public struct ToolCall: Codable, Sendable {
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

// MARK: - Tool Call Update

/// An incremental update to an existing tool call.
public struct ToolCallUpdate: Codable, Sendable {
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

// MARK: - Tool Call Status

/// The execution status of a tool call.
public enum ToolCallStatus: String, Codable, Sendable {
  /// The tool call is pending execution.
  case pending

  /// The tool call is currently executing.
  case inProgress = "in_progress"

  /// The tool call completed successfully.
  case completed

  /// The tool call failed.
  case failed
}

// MARK: - Tool Kind

/// The category of tool being invoked.
public enum ToolKind: String, Codable, Sendable {
  /// Reading a file or resource.
  case read

  /// Editing a file or resource.
  case edit

  /// Deleting a file or resource.
  case delete

  /// Moving or renaming a file or resource.
  case move

  /// Searching for content.
  case search

  /// Executing a command.
  case execute

  /// Agent thinking/reasoning.
  case think

  /// Fetching external data.
  case fetch

  /// Switching the session mode.
  case switchMode = "switch_mode"

  /// Other tool types.
  case other
}

// MARK: - Tool Call Content

/// Content displayed for a tool call.
public enum ToolCallContent: Codable, Sendable {
  case content(ToolCallContentBlock)
  case diff(Diff)
  case terminal(Terminal)

  private enum CodingKeys: String, CodingKey {
    case type
  }

  private enum ContentType: String, Codable {
    case content
    case diff
    case terminal
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ContentType.self, forKey: .type)

    switch type {
    case .content:
      self = .content(try ToolCallContentBlock(from: decoder))
    case .diff:
      self = .diff(try Diff(from: decoder))
    case .terminal:
      self = .terminal(try Terminal(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .content(let block):
      try block.encode(to: encoder)
    case .diff(let diff):
      try diff.encode(to: encoder)
    case .terminal(let terminal):
      try terminal.encode(to: encoder)
    }
  }
}

// MARK: - Tool Call Content Block

/// A content block wrapper for tool call content.
public struct ToolCallContentBlock: Codable, Sendable {
  private var type: String = "content"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The content blocks.
  public var content: [ContentBlock]

  public init(_meta: Meta = nil, content: [ContentBlock]) {
    self._meta = _meta
    self.content = content
  }
}

// MARK: - Diff

/// Represents a file diff (before and after).
public struct Diff: Codable, Sendable {
  private var type: String = "diff"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The new text content.
  public var newText: String?

  /// The old text content.
  public var oldText: String?

  /// The file path.
  public var path: String

  public init(
    _meta: Meta = nil,
    newText: String? = nil,
    oldText: String? = nil,
    path: String
  ) {
    self._meta = _meta
    self.newText = newText
    self.oldText = oldText
    self.path = path
  }
}

// MARK: - Tool Call Location

/// A location in a file affected by a tool call.
public struct ToolCallLocation: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The line number (1-based).
  public var line: Int?

  /// The file path (absolute).
  public var path: String

  public init(
    _meta: Meta = nil,
    line: Int? = nil,
    path: String
  ) {
    self._meta = _meta
    self.line = line
    self.path = path
  }
}
