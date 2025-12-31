// MARK: - Extensibility Types

import Foundation

// MARK: - Extension Request

/// An extension request for custom methods.
///
/// Extension methods are prefixed with underscore (_) and provide a way
/// to add custom functionality while maintaining protocol compatibility.
public struct ExtRequest: Codable, Sendable {
  /// The method name (should start with `_`).
  public var method: String

  /// The request parameters.
  public var params: AnyCodable?

  public init(method: String, params: AnyCodable? = nil) {
    self.method = method
    self.params = params
  }
}

// MARK: - Extension Response

/// Response to an extension request.
public struct ExtResponse: Codable, Sendable {
  /// The response result.
  public var result: AnyCodable?

  public init(result: AnyCodable? = nil) {
    self.result = result
  }
}

// MARK: - Extension Notification

/// An extension notification for custom one-way messages.
///
/// Extension notifications are prefixed with underscore (_) and provide
/// a way to send one-way messages for custom functionality.
public struct ExtNotification: Codable, Sendable {
  /// The method name (should start with `_`).
  public var method: String

  /// The notification parameters.
  public var params: AnyCodable?

  public init(method: String, params: AnyCodable? = nil) {
    self.method = method
    self.params = params
  }
}
