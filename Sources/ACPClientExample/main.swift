import Foundation
import SwiftACP
import StreamTransportClient

/// Example implementation of ACPClientDelegate
final class ExampleClientDelegate: ACPClientDelegate {
  func client(
    _ client: ACPClient,
    didReceiveSessionUpdate notification: SessionNotification
  ) async {
    let update = notification.update

    switch update {
    case .agentMessageChunk(let chunk):
      // Iterate through content blocks and print text
      for contentBlock in chunk.content {
        if case .text(let textContent) = contentBlock {
          print(textContent.text, terminator: "")
          fflush(stdout)
        }
      }

    case .toolCall(let toolCall):
      if let title = toolCall.title {
        print("\n🔧 \(title) (\(toolCall.status))")
      }

    case .toolCallUpdate(let update):
      if let status = update.status {
        print("🔧 Tool call `\(update.toolCallId)` updated: \(status)")
      }

    default:
      break
    }
  }

  func client(
    _ client: ACPClient,
    handleReadTextFile request: ReadTextFileRequest
  ) async throws -> ReadTextFileResponse {
    print("[Client] Read text file: \(request.path)")
    return ReadTextFileResponse(content: "Mock file content from Swift client")
  }

  func client(
    _ client: ACPClient,
    handleWriteTextFile request: WriteTextFileRequest
  ) async throws -> WriteTextFileResponse {
    print("[Client] Write text file: \(request.path)")
    return WriteTextFileResponse()
  }

  func client(
    _ client: ACPClient,
    handleRequestPermission request: RequestPermissionRequest
  ) async throws -> RequestPermissionResponse {
    print("\n🔐 Permission requested: \(request.toolCall.title ?? "unknown")")

    // For this example, auto-approve the first option
    if let firstOption = request.options.first {
      return RequestPermissionResponse(
        outcome: .selected(SelectedPermissionOutcome(optionId: firstOption.optionId))
      )
    }

    return RequestPermissionResponse(outcome: .cancelled)
  }

  func client(
    _ client: ACPClient,
    handleCreateTerminal request: CreateTerminalRequest
  ) async throws -> CreateTerminalResponse {
    print("[Client] Create terminal requested")
    return CreateTerminalResponse(terminalId: "mock-terminal")
  }

  func client(
    _ client: ACPClient,
    handleTerminalOutput request: TerminalOutputRequest
  ) async throws -> TerminalOutputResponse {
    print("[Client] Terminal output requested")
    return TerminalOutputResponse(output: "")
  }

  func client(
    _ client: ACPClient,
    handleReleaseTerminal request: ReleaseTerminalRequest
  ) async throws -> ReleaseTerminalResponse {
    print("[Client] Release terminal requested")
    return ReleaseTerminalResponse()
  }

  func client(
    _ client: ACPClient,
    handleWaitForTerminalExit request: WaitForTerminalExitRequest
  ) async throws -> WaitForTerminalExitResponse {
    print("[Client] Wait for terminal exit requested")
    return WaitForTerminalExitResponse(exitCode: 0)
  }

  func client(
    _ client: ACPClient,
    handleKillTerminalCommand request: KillTerminalCommandRequest
  ) async throws -> KillTerminalCommandResponse {
    print("[Client] Kill terminal command requested")
    return KillTerminalCommandResponse()
  }
}

@main
struct ACPClientExample {
  static func main() async throws {
    print("🚀 Starting ACP Client with ProcessTransport\n")

    // Get the path to the agent binary
    // Assuming the agent binary is in the typescript-sdk examples directory
    let agentPath = "/Users/luosheng/Projects/fork/typescript-sdk/src/examples/agent"

    print("📍 Agent binary: \(agentPath)\n")

    // Create the ProcessTransport to spawn the agent
    let transport = ProcessTransport(
      command: agentPath,
      arguments: []
    )

    // Create the ACPClient with the transport
    let client = ACPClient(transport: transport)
    let delegate = ExampleClientDelegate()

    do {
      // Set the delegate
      await client.setDelegate(delegate)

      // Connect to the agent
      print("📡 Connecting to agent...")
      try await client.connect()
      print("✅ Connected\n")

      // Step 1: Initialize the connection
      print("📡 Step 1: Initializing connection...")
      let initResponse = try await client.initialize(
        request: InitializeRequest(
          clientCapabilities: ClientCapabilities(
            fs: FileSystemCapability(
              readTextFile: true,
              writeTextFile: true
            )
          ),
          clientInfo: Implementation(name: "SwiftACPExample", version: "1.0.0"),
          protocolVersion: acpProtocolVersion
        )
      )

      print("✅ Initialized (protocol v\(initResponse.protocolVersion))\n")

      // Step 2: Create a new session
      print("📝 Step 2: Creating new session...")
      let sessionResponse = try await client.newSession(
        request: NewSessionRequest(
          cwd: FileManager.default.currentDirectoryPath,
          mcpServers: []
        )
      )

      let sessionId = sessionResponse.sessionId
      print("✅ Created session: \(sessionId)\n")

      // Step 3: Send a text prompt
      print("💬 Step 3: Sending prompt 'Hello, agent!'\n")
      print("Agent response:")
      print(String(repeating: "─", count: 50))

      let promptResponse = try await client.prompt(
        request: PromptRequest(
          prompt: [
            .text(TextContent(text: "Hello, agent!"))
          ],
          sessionId: sessionId
        )
      )

      print("\n" + String(repeating: "─", count: 50))
      print("\n✅ Agent completed with: \(promptResponse.stopReason)\n")

      // Disconnect
      try await client.disconnect()
      print("✅ Disconnected from agent")

    } catch {
      print("\n❌ Error: \(error)")
      try? await client.disconnect()
      throw error
    }
  }
}
