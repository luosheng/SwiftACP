// MARK: - ACP Client

import Foundation
import StreamTransportClient
import StreamTransportCore

/// An ACP client that communicates with an agent over a transport layer.
///
/// The client provides type-safe methods for all ACP agent methods and handles
/// JSON-RPC encoding/decoding. It uses ndJSON (newline-delimited JSON) framing.
///
/// Example usage:
/// ```swift
/// let transport = ProcessTransport(command: "opencode", arguments: ["acp"])
/// let client = ACPClient(transport: transport)
/// try await client.connect()
///
/// let initResponse = try await client.initialize(request: InitializeRequest(
///   clientInfo: Implementation(name: "MyApp", version: "1.0"),
///   protocolVersion: acpProtocolVersion
/// ))
/// ```
public actor ACPClient {
  // MARK: - Properties

  /// The underlying transport for communication.
  private let transport: any ClientTransport

  /// Delegate for handling agent-initiated requests and notifications.
  public weak var delegate: ACPClientDelegate?

  /// Pending requests awaiting responses, keyed by request ID.
  private var pendingRequests: [RequestId: PendingRequest] = [:]

  /// Counter for generating unique request IDs.
  private var nextRequestId: Int = 1

  /// Whether the client is currently connected.
  public private(set) var isConnected: Bool = false

  /// Task handling incoming messages.
  private var messageTask: Task<Void, Never>?

  /// JSON encoder configured for ACP.
  private let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }()

  /// JSON decoder configured for ACP.
  private let decoder = JSONDecoder()

  // MARK: - Initialization

  /// Creates a new ACP client with the specified transport.
  ///
  /// - Parameter transport: The client transport to use for communication.
  public init(transport: any ClientTransport) {
    self.transport = transport
  }

  // MARK: - Lifecycle

  /// Connects to the agent by starting the transport.
  ///
  /// - Throws: `ACPClientError.connectionFailed` if the connection fails.
  public func connect() async throws {
    guard !isConnected else { return }

    do {
      try await transport.start()
      isConnected = true
      startMessageLoop()
    } catch {
      throw ACPClientError.connectionFailed(error.localizedDescription)
    }
  }

  /// Sets the delegate for handling agent-initiated requests and notifications.
  ///
  /// - Parameter delegate: The delegate to handle agent requests.
  public func setDelegate(_ delegate: ACPClientDelegate?) {
    self.delegate = delegate
  }

  /// Disconnects from the agent by stopping the transport.
  public func disconnect() async throws {
    guard isConnected else { return }

    messageTask?.cancel()
    messageTask = nil

    try await transport.stop()
    isConnected = false

    // Cancel all pending requests
    for (_, pending) in pendingRequests {
      pending.resumeThrowing(ACPClientError.transportClosed)
    }
    pendingRequests.removeAll()
  }

  // MARK: - Agent Methods (Client → Agent)

  /// Initializes the connection with the agent.
  ///
  /// This must be the first method called after connecting. It negotiates
  /// the protocol version and exchanges capability information.
  ///
  /// - Parameter request: The initialization request parameters.
  /// - Returns: The agent's initialization response.
  public func initialize(request: InitializeRequest) async throws -> InitializeResponse {
    try await sendRequest(method: AgentMethod.initialize.rawValue, params: request)
  }

  /// Authenticates with the agent using the specified method.
  ///
  /// - Parameter request: The authentication request parameters.
  /// - Returns: The authentication response.
  public func authenticate(request: AuthenticateRequest) async throws -> AuthenticateResponse {
    try await sendRequest(method: AgentMethod.authenticate.rawValue, params: request)
  }

  /// Creates a new session with the agent.
  ///
  /// - Parameter request: The new session request parameters.
  /// - Returns: The new session response containing the session ID.
  public func newSession(request: NewSessionRequest) async throws -> NewSessionResponse {
    try await sendRequest(method: AgentMethod.sessionNew.rawValue, params: request)
  }

  /// Loads an existing session.
  ///
  /// - Parameter request: The load session request parameters.
  /// - Returns: The load session response.
  public func loadSession(request: LoadSessionRequest) async throws -> LoadSessionResponse {
    try await sendRequest(method: AgentMethod.sessionLoad.rawValue, params: request)
  }

  /// Sends a prompt to the agent within a session.
  ///
  /// - Parameter request: The prompt request parameters.
  /// - Returns: The prompt response with the stop reason.
  public func prompt(request: PromptRequest) async throws -> PromptResponse {
    try await sendRequest(method: AgentMethod.sessionPrompt.rawValue, params: request)
  }

  /// Sets the operating mode for a session.
  ///
  /// - Parameter request: The set mode request parameters.
  /// - Returns: The set mode response.
  public func setSessionMode(request: SetSessionModeRequest) async throws
    -> SetSessionModeResponse
  {
    try await sendRequest(method: AgentMethod.sessionSetMode.rawValue, params: request)
  }

  /// Cancels ongoing operations for a session.
  ///
  /// This is a notification (no response expected).
  ///
  /// - Parameter notification: The cancel notification parameters.
  public func cancel(notification: CancelNotification) async throws {
    try await sendNotification(method: AgentMethod.sessionCancel.rawValue, params: notification)
  }

  // MARK: - Private Methods

  /// Generates the next unique request ID.
  private func generateRequestId() -> RequestId {
    let id = nextRequestId
    nextRequestId += 1
    return .int(id)
  }

  /// Sends a JSON-RPC request and waits for the response.
  private func sendRequest<Params: Codable & Sendable, Response: Codable & Sendable>(
    method: String,
    params: Params
  ) async throws -> Response {
    guard isConnected else {
      throw ACPClientError.notConnected
    }

    let id = generateRequestId()
    let request = JSONRPCRequest(id: id, method: method, params: params)

    let data: Data
    do {
      data = try encoder.encode(request)
    } catch {
      throw ACPClientError.encodingFailed(error.localizedDescription)
    }

    // Append newline for ndJSON framing
    var framedData = data
    framedData.append(contentsOf: [0x0A])  // newline

    // DEBUG: Print the request JSON
    if let jsonString = String(data: data, encoding: .utf8) {
      fputs("[DEBUG] Sending request: \(jsonString)\n", stderr)
    }

    // Send the data first
    do {
      try await transport.send(framedData)
    } catch {
      throw ACPClientError.connectionFailed(error.localizedDescription)
    }

    // Then wait for the response
    return try await withCheckedThrowingContinuation { continuation in
      let pending = PendingRequest(
        resumeReturning: { continuation.resume(returning: $0 as! Response) },
        resumeThrowing: { continuation.resume(throwing: $0) },
        decode: { data, decoder in try decoder.decode(Response.self, from: data) }
      )
      pendingRequests[id] = pending
    }
  }

  /// Removes a pending request by ID (helper for async context).
  private func removePendingRequest(_ id: RequestId) {
    pendingRequests.removeValue(forKey: id)
  }

  /// Sends a JSON-RPC notification (no response expected).
  private func sendNotification<Params: Codable & Sendable>(
    method: String,
    params: Params
  ) async throws {
    guard isConnected else {
      throw ACPClientError.notConnected
    }

    let notification = JSONRPCNotification(method: method, params: params)

    let data: Data
    do {
      data = try encoder.encode(notification)
    } catch {
      throw ACPClientError.encodingFailed(error.localizedDescription)
    }

    // Append newline for ndJSON framing
    var framedData = data
    framedData.append(contentsOf: [0x0A])  // newline

    try await transport.send(framedData)
  }

  /// Starts the message processing loop.
  private func startMessageLoop() {
    messageTask = Task { [weak self] in
      guard let self = self else { return }

      for await data in await transport.messages {
        await self.handleIncomingData(data)
      }

      // Transport closed
      await self.handleTransportClosed()
    }
  }

  /// Handles incoming data from the transport.
  private func handleIncomingData(_ data: Data) async {
    // Split by newlines for ndJSON
    let lines = data.split(separator: 0x0A)

    for line in lines {
      guard !line.isEmpty else { continue }

      await processMessage(Data(line))
    }
  }

  /// Processes a single JSON-RPC message.
  private func processMessage(_ data: Data) async {
    // First, try to decode as a response (has id and result/error)
    if let response = try? decodeResponse(data) {
      await handleResponse(response)
      return
    }

    // Try to decode as a request from the agent
    if let request = try? decodeAgentRequest(data) {
      await handleAgentRequest(request)
      return
    }

    // Try to decode as a notification
    if let notification = try? decodeNotification(data) {
      await handleNotification(notification)
      return
    }

    // Unknown message format - log and ignore
  }

  /// Decodes a JSON-RPC response.
  private func decodeResponse(_ data: Data) throws -> IncomingResponse {
    // Try success response first
    struct SuccessEnvelope: Codable {
      let jsonrpc: String
      let id: RequestId
      let result: AnyCodable
    }

    if let envelope = try? decoder.decode(SuccessEnvelope.self, from: data) {
      return .success(id: envelope.id, data: data)
    }

    // Try error response
    let errorResponse = try decoder.decode(JSONRPCErrorResponse.self, from: data)
    return .error(id: errorResponse.id, error: errorResponse.error)
  }

  /// Decodes a JSON-RPC request from the agent.
  private func decodeAgentRequest(_ data: Data) throws -> IncomingRequest {
    struct RequestEnvelope: Codable {
      let jsonrpc: String
      let id: RequestId
      let method: String
    }

    let envelope = try decoder.decode(RequestEnvelope.self, from: data)
    return IncomingRequest(id: envelope.id, method: envelope.method, data: data)
  }

  /// Decodes a JSON-RPC notification.
  private func decodeNotification(_ data: Data) throws -> IncomingNotification {
    struct NotificationEnvelope: Codable {
      let jsonrpc: String
      let method: String
    }

    let envelope = try decoder.decode(NotificationEnvelope.self, from: data)
    return IncomingNotification(method: envelope.method, data: data)
  }

  /// Handles a response from the agent.
  private func handleResponse(_ response: IncomingResponse) async {
    switch response {
    case .success(let id, let data):
      guard let pending = pendingRequests.removeValue(forKey: id) else { return }

      do {
        // Decode the entire response with AnyCodable result
        struct ResponseEnvelope: Decodable {
          let jsonrpc: String
          let id: RequestId
          let result: AnyCodable
        }

        let envelope = try decoder.decode(ResponseEnvelope.self, from: data)

        // Re-encode and decode to the expected type via pending.decode
        let resultData = try encoder.encode(envelope.result)
        let decoded = try pending.decode(resultData, decoder)

        pending.resumeReturning(decoded)
      } catch {
        pending.resumeThrowing(ACPClientError.decodingFailed(error.localizedDescription))
      }

    case .error(let id, let error):
      guard let pending = pendingRequests.removeValue(forKey: id) else { return }
      pending.resumeThrowing(ACPClientError.rpcError(error))
    }
  }

  /// Handles a request from the agent.
  private func handleAgentRequest(_ request: IncomingRequest) async {
    guard let delegate = delegate else {
      // Send error response - no delegate to handle request
      await sendErrorResponse(
        id: request.id,
        error: JSONRPCError(code: .internalError, message: "No delegate to handle request")
      )
      return
    }

    do {
      let response: Any = try await dispatchAgentRequest(request, to: delegate)
      await sendSuccessResponse(id: request.id, result: response)
    } catch {
      await sendErrorResponse(
        id: request.id,
        error: JSONRPCError(code: .internalError, message: error.localizedDescription)
      )
    }
  }

  /// Dispatches an agent request to the appropriate delegate method.
  private func dispatchAgentRequest(_ request: IncomingRequest, to delegate: ACPClientDelegate)
    async throws -> Any
  {
    switch request.method {
    case ClientMethod.fsReadTextFile.rawValue:
      let params = try decodeParams(ReadTextFileRequest.self, from: request.data)
      return try await delegate.client(self, handleReadTextFile: params)

    case ClientMethod.fsWriteTextFile.rawValue:
      let params = try decodeParams(WriteTextFileRequest.self, from: request.data)
      return try await delegate.client(self, handleWriteTextFile: params)

    case ClientMethod.sessionRequestPermission.rawValue:
      let params = try decodeParams(RequestPermissionRequest.self, from: request.data)
      return try await delegate.client(self, handleRequestPermission: params)

    case ClientMethod.terminalCreate.rawValue:
      let params = try decodeParams(CreateTerminalRequest.self, from: request.data)
      return try await delegate.client(self, handleCreateTerminal: params)

    case ClientMethod.terminalOutput.rawValue:
      let params = try decodeParams(TerminalOutputRequest.self, from: request.data)
      return try await delegate.client(self, handleTerminalOutput: params)

    case ClientMethod.terminalRelease.rawValue:
      let params = try decodeParams(ReleaseTerminalRequest.self, from: request.data)
      return try await delegate.client(self, handleReleaseTerminal: params)

    case ClientMethod.terminalWaitForExit.rawValue:
      let params = try decodeParams(WaitForTerminalExitRequest.self, from: request.data)
      return try await delegate.client(self, handleWaitForTerminalExit: params)

    case ClientMethod.terminalKill.rawValue:
      let params = try decodeParams(KillTerminalCommandRequest.self, from: request.data)
      return try await delegate.client(self, handleKillTerminalCommand: params)

    default:
      throw JSONRPCError(code: .methodNotFound, message: "Unknown method: \(request.method)")
    }
  }

  /// Decodes request parameters from raw data.
  private func decodeParams<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
    let envelope = try decoder.decode(RequestParamsEnvelope<T>.self, from: data)
    return envelope.params
  }

  /// Handles a notification from the agent.
  private func handleNotification(_ notification: IncomingNotification) async {
    guard notification.method == ClientMethod.sessionUpdate.rawValue else { return }

    do {
      struct NotificationEnvelope: Codable {
        let jsonrpc: String
        let method: String
        let params: SessionNotification
      }

      let envelope = try decoder.decode(NotificationEnvelope.self, from: notification.data)
      await delegate?.client(self, didReceiveSessionUpdate: envelope.params)
    } catch {
      // Log decoding error
    }
  }

  /// Sends a success response to the agent.
  private func sendSuccessResponse(id: RequestId, result: Any) async {
    guard let encodableResult = result as? any Encodable else { return }

    struct ResponseEnvelope: Encodable {
      let jsonrpc: String
      let id: RequestId
      let result: AnyEncodable

      init(id: RequestId, result: any Encodable) {
        self.jsonrpc = jsonRPCVersion
        self.id = id
        self.result = AnyEncodable(result)
      }
    }

    do {
      var data = try encoder.encode(ResponseEnvelope(id: id, result: encodableResult))
      data.append(contentsOf: [0x0A])
      try await transport.send(data)
    } catch {
      // Log encoding error
    }
  }

  /// Sends an error response to the agent.
  private func sendErrorResponse(id: RequestId, error: JSONRPCError) async {
    let errorResponse = JSONRPCErrorResponse(id: id, error: error)

    do {
      var data = try encoder.encode(errorResponse)
      data.append(contentsOf: [0x0A])
      try await transport.send(data)
    } catch {
      // Log encoding error
    }
  }

  /// Handles transport closure.
  private func handleTransportClosed() async {
    isConnected = false

    for pending in pendingRequests.values {
      pending.resumeThrowing(ACPClientError.transportClosed)
    }
    pendingRequests.removeAll()
  }
}

// MARK: - Supporting Types

/// A pending request awaiting a response.
private struct PendingRequest {
  let resumeReturning: (Any) -> Void
  let resumeThrowing: (Error) -> Void
  let decode: (Data, JSONDecoder) throws -> Any
}

/// An incoming response from the agent.
private enum IncomingResponse {
  case success(id: RequestId, data: Data)
  case error(id: RequestId, error: JSONRPCError)
}

/// An incoming request from the agent.
private struct IncomingRequest {
  let id: RequestId
  let method: String
  let data: Data
}

/// An incoming notification from the agent.
private struct IncomingNotification {
  let method: String
  let data: Data
}

/// Envelope for decoding request parameters.
private struct RequestParamsEnvelope<Params: Codable>: Codable {
  let jsonrpc: String
  let id: RequestId
  let method: String
  let params: Params
}
