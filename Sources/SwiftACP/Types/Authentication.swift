// MARK: - Authentication Types

import Foundation

// MARK: - Auth Method

/// Describes an available authentication method.
public struct AuthMethod: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional description providing more details about this authentication method.
  public var description: String?

  /// Unique identifier for this authentication method.
  public var id: String

  /// Human-readable name of the authentication method.
  public var name: String

  public init(
    _meta: Meta = nil,
    description: String? = nil,
    id: String,
    name: String
  ) {
    self._meta = _meta
    self.description = description
    self.id = id
    self.name = name
  }
}

// MARK: - Implementation

/// Information about a client or agent implementation.
public struct Implementation: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The name of the implementation.
  public var name: String

  /// Optional title of the implementation.
  public var title: String?

  /// The version of the implementation.
  public var version: String

  public init(
    _meta: Meta = nil,
    name: String,
    title: String? = nil,
    version: String
  ) {
    self._meta = _meta
    self.name = name
    self.title = title
    self.version = version
  }
}

// MARK: - Protocol Version

/// The ACP protocol version as a UInt16.
public typealias ProtocolVersion = UInt16
