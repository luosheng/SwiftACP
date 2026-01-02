// MARK: - Client Methods (Agent → Client)

import Foundation

// MARK: - Read Text File

/// Request parameters for the fs/read_text_file method.
public struct ReadTextFileRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Maximum number of lines to read.
  public var limit: Int?

  /// Starting line number (1-based).
  public var line: Int?

  /// The absolute path to the file.
  public var path: String

  /// The ID of the session.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    limit: Int? = nil,
    line: Int? = nil,
    path: String,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.limit = limit
    self.line = line
    self.path = path
    self.sessionId = sessionId
  }
}

/// Response to the fs/read_text_file method.
public struct ReadTextFileResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The file content.
  public var content: String

  public init(_meta: Meta = nil, content: String) {
    self._meta = _meta
    self.content = content
  }
}

// MARK: - Write Text File

/// Request parameters for the fs/write_text_file method.
public struct WriteTextFileRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The content to write.
  public var content: String

  /// The absolute path to the file.
  public var path: String

  /// The ID of the session.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    content: String,
    path: String,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.content = content
    self.path = path
    self.sessionId = sessionId
  }
}

/// Response to the fs/write_text_file method.
public struct WriteTextFileResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  public init(_meta: Meta = nil) {
    self._meta = _meta
  }
}

// MARK: - Request Permission

/// Request parameters for the session/request_permission method.
public struct RequestPermissionRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The permission options to present to the user.
  public var options: [PermissionOption]

  /// The ID of the session.
  public var sessionId: SessionId

  /// The tool call update to request permission for.
  public var toolCall: ToolCallUpdate

  public init(
    _meta: Meta = nil,
    options: [PermissionOption],
    sessionId: SessionId,
    toolCall: ToolCallUpdate
  ) {
    self._meta = _meta
    self.options = options
    self.sessionId = sessionId
    self.toolCall = toolCall
  }
}

/// Response to the session/request_permission method.
public struct RequestPermissionResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The outcome of the permission request.
  public var outcome: RequestPermissionOutcome

  public init(_meta: Meta = nil, outcome: RequestPermissionOutcome) {
    self._meta = _meta
    self.outcome = outcome
  }
}

// MARK: - Create Terminal

/// Request parameters for the terminal/create method.
public struct CreateTerminalRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Arguments for the command.
  public var args: [String]?

  /// The command to execute.
  public var command: String

  /// The working directory.
  public var cwd: String?

  /// Environment variables.
  public var env: [EnvVariable]?

  /// Maximum bytes of output to capture.
  public var outputByteLimit: Int?

  /// The ID of the session.
  public var sessionId: SessionId

  public init(
    _meta: Meta = nil,
    args: [String]? = nil,
    command: String,
    cwd: String? = nil,
    env: [EnvVariable]? = nil,
    outputByteLimit: Int? = nil,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.args = args
    self.command = command
    self.cwd = cwd
    self.env = env
    self.outputByteLimit = outputByteLimit
    self.sessionId = sessionId
  }
}

/// Response to the terminal/create method.
public struct CreateTerminalResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the created terminal.
  public var terminalId: TerminalId

  public init(_meta: Meta = nil, terminalId: TerminalId) {
    self._meta = _meta
    self.terminalId = terminalId
  }
}

// MARK: - Terminal Output

/// Request parameters for the terminal/output method.
public struct TerminalOutputRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the session.
  public var sessionId: SessionId

  /// The ID of the terminal.
  public var terminalId: TerminalId

  public init(
    _meta: Meta = nil,
    sessionId: SessionId,
    terminalId: TerminalId
  ) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response to the terminal/output method.
public struct TerminalOutputResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The exit status if the command has exited.
  public var exitStatus: TerminalExitStatus?

  /// The terminal output.
  public var output: String

  /// Whether the output was truncated.
  public var truncated: Bool?

  public init(
    _meta: Meta = nil,
    exitStatus: TerminalExitStatus? = nil,
    output: String,
    truncated: Bool? = nil
  ) {
    self._meta = _meta
    self.exitStatus = exitStatus
    self.output = output
    self.truncated = truncated
  }
}

// MARK: - Release Terminal

/// Request parameters for the terminal/release method.
public struct ReleaseTerminalRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the session.
  public var sessionId: SessionId

  /// The ID of the terminal.
  public var terminalId: TerminalId

  public init(
    _meta: Meta = nil,
    sessionId: SessionId,
    terminalId: TerminalId
  ) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response to the terminal/release method.
public struct ReleaseTerminalResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  public init(_meta: Meta = nil) {
    self._meta = _meta
  }
}

// MARK: - Wait For Terminal Exit

/// Request parameters for the terminal/wait_for_exit method.
public struct WaitForTerminalExitRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the session.
  public var sessionId: SessionId

  /// The ID of the terminal.
  public var terminalId: TerminalId

  public init(
    _meta: Meta = nil,
    sessionId: SessionId,
    terminalId: TerminalId
  ) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response to the terminal/wait_for_exit method.
public struct WaitForTerminalExitResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The exit code of the command.
  public var exitCode: Int?

  /// The signal that terminated the command.
  public var signal: String?

  public init(
    _meta: Meta = nil,
    exitCode: Int? = nil,
    signal: String? = nil
  ) {
    self._meta = _meta
    self.exitCode = exitCode
    self.signal = signal
  }
}

// MARK: - Kill Terminal Command

/// Request parameters for the terminal/kill method.
public struct KillTerminalCommandRequest: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the session.
  public var sessionId: SessionId

  /// The ID of the terminal.
  public var terminalId: TerminalId

  public init(
    _meta: Meta = nil,
    sessionId: SessionId,
    terminalId: TerminalId
  ) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response to the terminal/kill method.
public struct KillTerminalCommandResponse: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  public init(_meta: Meta = nil) {
    self._meta = _meta
  }
}

// MARK: - Session Notification

/// Notification sent by the agent for session updates.
public struct SessionNotification: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the session.
  public var sessionId: SessionId

  /// The session update.
  public var update: SessionUpdate

  public init(
    _meta: Meta = nil,
    sessionId: SessionId,
    update: SessionUpdate
  ) {
    self._meta = _meta
    self.sessionId = sessionId
    self.update = update
  }
}

// MARK: - Method Names

/// Method names for client-side methods.
public enum ClientMethod: String, Sendable {
  case fsReadTextFile = "fs/read_text_file"
  case fsWriteTextFile = "fs/write_text_file"
  case sessionRequestPermission = "session/request_permission"
  case sessionUpdate = "session/update"
  case terminalCreate = "terminal/create"
  case terminalOutput = "terminal/output"
  case terminalRelease = "terminal/release"
  case terminalWaitForExit = "terminal/wait_for_exit"
  case terminalKill = "terminal/kill"
}
