// MARK: - Plan Types

import Foundation

// MARK: - Plan

/// An agent's plan for completing a task.
public struct Plan: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The entries in the plan.
  public var entries: [PlanEntry]

  public init(_meta: Meta = nil, entries: [PlanEntry] = []) {
    self._meta = _meta
    self.entries = entries
  }
}

// MARK: - Plan Entry

/// An individual step in an agent's plan.
public struct PlanEntry: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Description of this plan entry.
  public var content: String

  /// The priority of this entry.
  public var priority: PlanEntryPriority?

  /// The current status of this entry.
  public var status: PlanEntryStatus?

  public init(
    _meta: Meta = nil,
    content: String,
    priority: PlanEntryPriority? = nil,
    status: PlanEntryStatus? = nil
  ) {
    self._meta = _meta
    self.content = content
    self.priority = priority
    self.status = status
  }
}

// MARK: - Plan Entry Status

/// The execution status of a plan entry.
public enum PlanEntryStatus: String, Codable, Sendable {
  /// The entry has not been started.
  case pending

  /// The entry is currently being worked on.
  case inProgress = "in_progress"

  /// The entry has been completed.
  case completed
}

// MARK: - Plan Entry Priority

/// The priority level of a plan entry.
public enum PlanEntryPriority: String, Codable, Sendable {
  /// High priority.
  case high

  /// Medium priority.
  case medium

  /// Low priority.
  case low
}
