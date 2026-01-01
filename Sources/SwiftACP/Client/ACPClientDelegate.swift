// MARK: - ACP Client Delegate

import Foundation

/// Delegate protocol for handling agent-initiated requests and notifications.
///
/// The ACP agent can send requests to the client for file operations, terminal management,
/// and permission requests. The client must implement these methods to respond appropriately.
/// Session notifications are also delivered through this delegate.
public protocol ACPClientDelegate: AnyObject, Sendable {
  // MARK: - Session Notifications

  /// Called when the agent sends a session update notification.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the notification.
  ///   - notification: The session notification containing the update.
  func client(_ client: ACPClient, didReceiveSessionUpdate notification: SessionNotification) async

  // MARK: - File System Operations

  /// Called when the agent requests to read a text file.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The read text file request parameters.
  /// - Returns: The file content response.
  func client(_ client: ACPClient, handleReadTextFile request: ReadTextFileRequest) async throws
    -> ReadTextFileResponse

  /// Called when the agent requests to write a text file.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The write text file request parameters.
  /// - Returns: The write confirmation response.
  func client(_ client: ACPClient, handleWriteTextFile request: WriteTextFileRequest) async throws
    -> WriteTextFileResponse

  // MARK: - Permission Handling

  /// Called when the agent requests permission for a tool call.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The permission request parameters.
  /// - Returns: The permission outcome response.
  func client(_ client: ACPClient, handleRequestPermission request: RequestPermissionRequest)
    async throws -> RequestPermissionResponse

  // MARK: - Terminal Operations

  /// Called when the agent requests to create a terminal.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The create terminal request parameters.
  /// - Returns: The created terminal response.
  func client(_ client: ACPClient, handleCreateTerminal request: CreateTerminalRequest) async throws
    -> CreateTerminalResponse

  /// Called when the agent requests terminal output.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The terminal output request parameters.
  /// - Returns: The terminal output response.
  func client(_ client: ACPClient, handleTerminalOutput request: TerminalOutputRequest) async throws
    -> TerminalOutputResponse

  /// Called when the agent requests to release a terminal.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The release terminal request parameters.
  /// - Returns: The release confirmation response.
  func client(_ client: ACPClient, handleReleaseTerminal request: ReleaseTerminalRequest)
    async throws -> ReleaseTerminalResponse

  /// Called when the agent requests to wait for terminal exit.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The wait for exit request parameters.
  /// - Returns: The exit status response.
  func client(_ client: ACPClient, handleWaitForTerminalExit request: WaitForTerminalExitRequest)
    async throws -> WaitForTerminalExitResponse

  /// Called when the agent requests to kill a terminal command.
  ///
  /// - Parameters:
  ///   - client: The ACP client that received the request.
  ///   - request: The kill terminal request parameters.
  /// - Returns: The kill confirmation response.
  func client(_ client: ACPClient, handleKillTerminalCommand request: KillTerminalCommandRequest)
    async throws -> KillTerminalCommandResponse
}
