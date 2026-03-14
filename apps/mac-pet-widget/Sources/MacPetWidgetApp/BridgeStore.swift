import Foundation

@MainActor
final class BridgeStore: ObservableObject {
  enum ConnectionState {
    case connecting
    case connected
    case degraded

    var title: String {
      switch self {
      case .connecting:
        return "connecting"
      case .connected:
        return "connected"
      case .degraded:
        return "degraded"
      }
    }
  }

  @Published var status: MergedStatus = .placeholder
  @Published var connectionState: ConnectionState = .connecting
  @Published var bridgeURLString: String
  @Published var bubbleVisible: Bool

  private let session: URLSession
  private var webSocketTask: URLSessionWebSocketTask?
  private var listenTask: Task<Void, Never>?
  private var pollTask: Task<Void, Never>?
  private var reconnectTask: Task<Void, Never>?
  private var started = false

  init(session: URLSession = .shared) {
    self.session = session
    self.bridgeURLString = UserDefaults.standard.string(forKey: "clawpet.bridgeURL") ?? "http://127.0.0.1:8787"
    self.bubbleVisible = UserDefaults.standard.object(forKey: "clawpet.bubbleVisible") as? Bool ?? true
  }

  func start() {
    guard !started else { return }
    started = true

    Task {
      await refreshStatus(source: "startup")
      await connectWebSocket()
      startPolling()
    }
  }

  func stop() {
    listenTask?.cancel()
    pollTask?.cancel()
    reconnectTask?.cancel()
    webSocketTask?.cancel(with: .normalClosure, reason: nil)
    started = false
  }

  func refreshNow() {
    Task {
      await refreshStatus(source: "manual")
    }
  }

  func setBridgeURL(_ value: String) {
    bridgeURLString = value.trimmingCharacters(in: .whitespacesAndNewlines)
    UserDefaults.standard.set(bridgeURLString, forKey: "clawpet.bridgeURL")
    reconnectWebSocket()
    refreshNow()
  }

  func toggleBubble() {
    bubbleVisible.toggle()
    status.ui.showBubble = bubbleVisible
    UserDefaults.standard.set(bubbleVisible, forKey: "clawpet.bubbleVisible")
  }

  func feed() {
    Task {
      await interact(path: "/api/pet/feed")
    }
  }

  func pat() {
    Task {
      await interact(path: "/api/pet/pat")
    }
  }

  private var httpBaseURL: URL? {
    URL(string: bridgeURLString)
  }

  private var wsURL: URL? {
    guard var comps = URLComponents(string: bridgeURLString) else { return nil }
    comps.scheme = comps.scheme == "https" ? "wss" : "ws"
    comps.path = "/ws"
    return comps.url
  }

  private func startPolling() {
    pollTask?.cancel()
    pollTask = Task {
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(4))
        await refreshStatus(source: "poll")
      }
    }
  }

  private func reconnectWebSocket() {
    webSocketTask?.cancel(with: .goingAway, reason: nil)
    listenTask?.cancel()
    reconnectTask?.cancel()

    reconnectTask = Task {
      try? await Task.sleep(for: .milliseconds(200))
      await connectWebSocket()
    }
  }

  private func connectWebSocket() async {
    guard let wsURL else {
      connectionState = .degraded
      status.openclaw.summary = "Invalid bridge URL"
      return
    }

    connectionState = .connecting

    webSocketTask?.cancel(with: .goingAway, reason: nil)
    let task = session.webSocketTask(with: wsURL)
    webSocketTask = task
    task.resume()

    listenTask?.cancel()
    listenTask = Task {
      await listen(task: task)
    }
  }

  private func listen(task: URLSessionWebSocketTask) async {
    while !Task.isCancelled {
      do {
        let message = try await task.receive()
        switch message {
        case .string(let string):
          try handleWebSocketString(string)
        case .data(let data):
          if let string = String(data: data, encoding: .utf8) {
            try handleWebSocketString(string)
          }
        @unknown default:
          continue
        }
      } catch {
        connectionState = .degraded
        status.openclaw.online = false
        status.openclaw.agentState = .offline
        status.openclaw.summary = "WS disconnected, retrying..."

        reconnectTask?.cancel()
        reconnectTask = Task {
          try? await Task.sleep(for: .seconds(2))
          await connectWebSocket()
        }
        break
      }
    }
  }

  private func handleWebSocketString(_ string: String) throws {
    let decoder = JSONDecoder()
    let event = try decoder.decode(StatusEventEnvelope.self, from: Data(string.utf8))
    status = event.payload
    status.ui.showBubble = bubbleVisible
    connectionState = .connected
  }

  private func refreshStatus(source: String) async {
    guard let url = URL(string: "/api/status", relativeTo: httpBaseURL) else {
      connectionState = .degraded
      status.openclaw.summary = "Invalid status URL"
      return
    }

    do {
      var request = URLRequest(url: url)
      request.timeoutInterval = 3
      let (data, _) = try await session.data(for: request)
      let decoder = JSONDecoder()
      var value = try decoder.decode(MergedStatus.self, from: data)
      value.ui.showBubble = bubbleVisible
      status = value
      if source != "poll" {
        connectionState = .connected
      }
    } catch {
      connectionState = .degraded
      status.openclaw.online = false
      status.openclaw.agentState = .offline
      status.openclaw.summary = "HTTP failed: \(error.localizedDescription)"
    }
  }

  private func interact(path: String) async {
    guard let url = URL(string: path, relativeTo: httpBaseURL) else { return }

    do {
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.timeoutInterval = 3
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = Data("{}".utf8)

      let (data, _) = try await session.data(for: request)
      let decoder = JSONDecoder()
      let petState = try decoder.decode(PetState.self, from: data)
      status.pet = petState
      status.ui.showBubble = bubbleVisible
      connectionState = .connected
    } catch {
      connectionState = .degraded
      status.openclaw.summary = "Action failed: \(error.localizedDescription)"
    }
  }
}
