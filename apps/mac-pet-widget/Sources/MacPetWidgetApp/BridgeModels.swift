import Foundation

enum AgentState: String, Codable {
  case idle
  case thinking
  case toolRunning = "tool_running"
  case error
  case offline
  case taskCompleted = "task_completed"
}

struct OpenClawSnapshot: Codable {
  var online: Bool
  var agentState: AgentState
  var toolName: String?
  var summary: String?
  var lastCompleted: String?
  var usage: String?
  var updatedAt: String
}

struct PetState: Codable {
  var name: String
  var level: Int
  var exp: Int
  var hunger: Int
  var mood: Int
  var energy: Int
  var affection: Int
  var animation: String
  var updatedAt: String
}

struct WidgetUiState: Codable {
  var theme: String
  var showBubble: Bool
}

struct MergedStatus: Codable {
  var pet: PetState
  var openclaw: OpenClawSnapshot
  var ui: WidgetUiState

  static let placeholder = MergedStatus(
    pet: PetState(
      name: "Clawy",
      level: 1,
      exp: 0,
      hunger: 70,
      mood: 70,
      energy: 70,
      affection: 30,
      animation: "idle_breathe",
      updatedAt: ""
    ),
    openclaw: OpenClawSnapshot(
      online: false,
      agentState: .offline,
      toolName: nil,
      summary: "Connecting to bridge...",
      lastCompleted: nil,
      usage: nil,
      updatedAt: ""
    ),
    ui: WidgetUiState(theme: "retro_desktop", showBubble: true)
  )
}

struct StatusEventEnvelope: Codable {
  var type: String
  var payload: MergedStatus
  var timestamp: String
}
