// MARK: - JSON-RPC 2.0 Base Types

import Foundation

/// The JSON-RPC protocol version.
public let jsonRPCVersion = "2.0"

/// A request identifier that can be either a string or an integer.
public enum RequestId: Codable, Hashable, Sendable {
  case string(String)
  case int(Int)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let intValue = try? container.decode(Int.self) {
      self = .int(intValue)
    } else if let stringValue = try? container.decode(String.self) {
      self = .string(stringValue)
    } else {
      throw DecodingError.typeMismatch(
        RequestId.self,
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Expected String or Int for RequestId"
        )
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .int(let value):
      try container.encode(value)
    }
  }
}

// MARK: - JSON-RPC Request

/// A JSON-RPC 2.0 request message.
public struct JSONRPCRequest<Params: Codable & Sendable>: Codable, Sendable {
  /// The JSON-RPC version. Always "2.0".
  public let jsonrpc: String

  /// The request identifier.
  public let id: RequestId

  /// The method name.
  public let method: String

  /// The method parameters.
  public let params: Params?

  public init(id: RequestId, method: String, params: Params? = nil) {
    self.jsonrpc = jsonRPCVersion
    self.id = id
    self.method = method
    self.params = params
  }
}

// MARK: - JSON-RPC Notification

/// A JSON-RPC 2.0 notification message (no response expected).
public struct JSONRPCNotification<Params: Codable & Sendable>: Codable, Sendable {
  /// The JSON-RPC version. Always "2.0".
  public let jsonrpc: String

  /// The method name.
  public let method: String

  /// The method parameters.
  public let params: Params?

  public init(method: String, params: Params? = nil) {
    self.jsonrpc = jsonRPCVersion
    self.method = method
    self.params = params
  }
}

// MARK: - JSON-RPC Response

/// A successful JSON-RPC 2.0 response message.
public struct JSONRPCResponse<Result: Codable & Sendable>: Codable, Sendable {
  /// The JSON-RPC version. Always "2.0".
  public let jsonrpc: String

  /// The request identifier this response corresponds to.
  public let id: RequestId

  /// The result of the method call.
  public let result: Result

  public init(id: RequestId, result: Result) {
    self.jsonrpc = jsonRPCVersion
    self.id = id
    self.result = result
  }
}

/// A JSON-RPC 2.0 error response message.
public struct JSONRPCErrorResponse: Codable, Sendable {
  /// The JSON-RPC version. Always "2.0".
  public let jsonrpc: String

  /// The request identifier this response corresponds to.
  public let id: RequestId

  /// The error object.
  public let error: JSONRPCError

  public init(id: RequestId, error: JSONRPCError) {
    self.jsonrpc = jsonRPCVersion
    self.id = id
    self.error = error
  }
}

// MARK: - JSON-RPC Error

/// A JSON-RPC 2.0 error object.
public struct JSONRPCError: Codable, Sendable, Error {
  /// The error code.
  public let code: Int

  /// A short description of the error.
  public let message: String

  /// Additional information about the error.
  public let data: AnyCodable?

  public init(code: Int, message: String, data: AnyCodable? = nil) {
    self.code = code
    self.message = message
    self.data = data
  }

  public init(code: ErrorCode, message: String, data: AnyCodable? = nil) {
    self.code = code.rawValue
    self.message = message
    self.data = data
  }
}

// MARK: - Error Codes

/// Standard JSON-RPC 2.0 error codes and ACP-specific error codes.
public enum ErrorCode: Int, Codable, Sendable {
  /// Parse error - Invalid JSON was received.
  case parseError = -32700

  /// Invalid Request - The JSON sent is not a valid Request object.
  case invalidRequest = -32600

  /// Method not found - The method does not exist / is not available.
  case methodNotFound = -32601

  /// Invalid params - Invalid method parameter(s).
  case invalidParams = -32602

  /// Internal error - Internal JSON-RPC error.
  case internalError = -32603

  /// Session not found - The specified session does not exist.
  case sessionNotFound = -32000

  /// Authentication required - Authentication is required for this operation.
  case authRequired = -32002
}

// MARK: - AnyCodable

/// A type-erased Codable value for handling arbitrary JSON data.
public struct AnyCodable: Codable, @unchecked Sendable {
  public let value: Any

  public init(_ value: Any) {
    self.value = value
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self.value = NSNull()
    } else if let bool = try? container.decode(Bool.self) {
      self.value = bool
    } else if let int = try? container.decode(Int.self) {
      self.value = int
    } else if let double = try? container.decode(Double.self) {
      self.value = double
    } else if let string = try? container.decode(String.self) {
      self.value = string
    } else if let array = try? container.decode([AnyCodable].self) {
      self.value = array.map { $0.value }
    } else if let dictionary = try? container.decode([String: AnyCodable].self) {
      self.value = dictionary.mapValues { $0.value }
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Unable to decode AnyCodable"
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch value {
    case is NSNull:
      try container.encodeNil()
    case let bool as Bool:
      try container.encode(bool)
    case let int as Int:
      try container.encode(int)
    case let double as Double:
      try container.encode(double)
    case let string as String:
      try container.encode(string)
    case let array as [Any]:
      try container.encode(array.map { AnyCodable($0) })
    case let dictionary as [String: Any]:
      try container.encode(dictionary.mapValues { AnyCodable($0) })
    default:
      throw EncodingError.invalidValue(
        value,
        EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Unable to encode AnyCodable"
        )
      )
    }
  }
}

// MARK: - AnyEncodable

/// A type-erased Encodable wrapper for encoding response payloads.
public struct AnyEncodable: Encodable {
  private let encodeClosure: (Encoder) throws -> Void

  public init<T: Encodable>(_ value: T) {
    self.encodeClosure = value.encode(to:)
  }

  public func encode(to encoder: Encoder) throws {
    try encodeClosure(encoder)
  }
}

// MARK: - Meta

/// Type alias for the extensible _meta field used throughout ACP.
public typealias Meta = [String: AnyCodable]?
