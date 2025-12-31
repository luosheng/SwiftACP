// MARK: - Terminal Types

import Foundation

// MARK: - Type Aliases

/// Unique identifier for a terminal.
public typealias TerminalId = String

// MARK: - Terminal

/// A reference to an active terminal.
public struct Terminal: Codable, Sendable {
  private let type: String = "terminal"

  /// Extensible metadata field.
  public var _meta: Meta

  /// The terminal identifier.
  public var terminalId: TerminalId

  public init(_meta: Meta = nil, terminalId: TerminalId) {
    self._meta = _meta
    self.terminalId = terminalId
  }
}

// MARK: - Terminal Exit Status

/// The exit status of a terminal command.
public struct TerminalExitStatus: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The exit code of the command (0 or greater).
  public var exitCode: Int?

  /// The signal that terminated the command, if any.
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

// MARK: - Environment Variable

/// An environment variable for terminal commands.
public struct EnvVariable: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The variable name.
  public var name: String

  /// The variable value.
  public var value: String

  public init(_meta: Meta = nil, name: String, value: String) {
    self._meta = _meta
    self.name = name
    self.value = value
  }
}
