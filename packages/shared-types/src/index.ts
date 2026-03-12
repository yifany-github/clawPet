export type AgentState =
  | "idle"
  | "thinking"
  | "tool_running"
  | "error"
  | "offline"
  | "task_completed";

export interface OpenClawSnapshot {
  online: boolean;
  agentState: AgentState;
  toolName?: string;
  summary?: string;
  lastCompleted?: string;
  usage?: string;
  updatedAt: string;
}

export interface PetState {
  name: string;
  level: number;
  exp: number;
  hunger: number;
  mood: number;
  energy: number;
  affection: number;
  animation: string;
  updatedAt: string;
}

export interface UiState {
  theme: string;
  showBubble: boolean;
}

export interface MergedStatus {
  pet: PetState;
  openclaw: OpenClawSnapshot;
  ui: UiState;
}

export interface StatusEvent {
  type:
    | "openclaw.updated"
    | "pet.updated"
    | "pet.interacted"
    | "system.warning"
    | "system.info";
  payload: MergedStatus;
  timestamp: string;
}

export function createDefaultOpenClawSnapshot(): OpenClawSnapshot {
  return {
    online: false,
    agentState: "offline",
    summary: "Bridge is starting",
    updatedAt: new Date().toISOString()
  };
}

export function createDefaultPetState(): PetState {
  return {
    name: "Clawy",
    level: 1,
    exp: 0,
    hunger: 70,
    mood: 70,
    energy: 70,
    affection: 30,
    animation: "idle_breathe",
    updatedAt: new Date().toISOString()
  };
}

export function createDefaultUiState(): UiState {
  return {
    theme: "retro_desktop",
    showBubble: true
  };
}

export function createDefaultMergedStatus(): MergedStatus {
  return {
    pet: createDefaultPetState(),
    openclaw: createDefaultOpenClawSnapshot(),
    ui: createDefaultUiState()
  };
}
