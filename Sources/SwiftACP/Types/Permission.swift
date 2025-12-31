// MARK: - Permission Types

import Foundation

// MARK: - Type Aliases

/// Unique identifier for a permission option.
public typealias PermissionOptionId = String

// MARK: - Permission Option

/// An option presented to the user for permission requests.
public struct PermissionOption: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The kind of permission this option represents.
  public var kind: PermissionOptionKind

  /// Human-readable name for this option.
  public var name: String

  /// Unique identifier for this option.
  public var optionId: PermissionOptionId

  public init(
    _meta: Meta = nil,
    kind: PermissionOptionKind,
    name: String,
    optionId: PermissionOptionId
  ) {
    self._meta = _meta
    self.kind = kind
    self.name = name
    self.optionId = optionId
  }
}

// MARK: - Permission Option Kind

/// The behavior of a permission option.
public enum PermissionOptionKind: String, Codable, Sendable {
  /// Allow this operation for this request only.
  case allowOnce = "allow_once"

  /// Allow this operation always (for the session).
  case allowAlways = "allow_always"

  /// Reject this operation for this request only.
  case rejectOnce = "reject_once"

  /// Reject this operation always (for the session).
  case rejectAlways = "reject_always"
}

// MARK: - Request Permission Outcome

/// The outcome of a permission request.
public enum RequestPermissionOutcome: Codable, Sendable {
  /// The request was cancelled (e.g., by `session/cancel`).
  case cancelled

  /// The user selected an option.
  case selected(SelectedPermissionOutcome)

  private enum CodingKeys: String, CodingKey {
    case outcome
  }

  private enum OutcomeType: String, Codable {
    case cancelled
    case selected
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(OutcomeType.self, forKey: .outcome)

    switch type {
    case .cancelled:
      self = .cancelled
    case .selected:
      self = .selected(try SelectedPermissionOutcome(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .cancelled:
      try container.encode(OutcomeType.cancelled, forKey: .outcome)
    case .selected(let outcome):
      try container.encode(OutcomeType.selected, forKey: .outcome)
      try outcome.encode(to: encoder)
    }
  }
}

// MARK: - Selected Permission Outcome

/// The outcome when a user selects a permission option.
public struct SelectedPermissionOutcome: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The ID of the selected option.
  public var optionId: PermissionOptionId

  public init(_meta: Meta = nil, optionId: PermissionOptionId) {
    self._meta = _meta
    self.optionId = optionId
  }
}
