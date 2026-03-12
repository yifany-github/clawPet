import {
  createDefaultPetState,
  type OpenClawSnapshot,
  type PetState
} from "@clawpet/shared-types";

export interface EngineOptions {
  hungerDecayPerMinute: number;
  energyDecayPerMinute: number;
  moodDecayPerMinute: number;
}

export interface PetStateEngine {
  getState(): PetState;
  tick(now?: Date): PetState;
  applyOpenClaw(snapshot: OpenClawSnapshot): PetState;
  feed(amount?: number): PetState;
  pat(amount?: number): PetState;
}

const DEFAULT_OPTIONS: EngineOptions = {
  hungerDecayPerMinute: 2,
  energyDecayPerMinute: 1.2,
  moodDecayPerMinute: 0.8
};

function clamp(value: number, min = 0, max = 100): number {
  return Math.max(min, Math.min(max, Math.round(value)));
}

function levelFromExp(exp: number): number {
  return Math.floor(exp / 100) + 1;
}

function animationFromOpenClaw(snapshot: OpenClawSnapshot): string {
  if (!snapshot.online || snapshot.agentState === "offline") {
    return "sleep_offline";
  }

  switch (snapshot.agentState) {
    case "idle":
      return "idle_breathe";
    case "thinking":
      return "thinking_lookaround";
    case "tool_running":
      return "work_typing";
    case "error":
      return "error_sweat";
    case "task_completed":
      return "happy_dance";
    default:
      return "idle_breathe";
  }
}

function reduceMoodByNeeds(state: PetState): PetState {
  let mood = state.mood;

  if (state.hunger < 30) mood -= 8;
  if (state.energy < 25) mood -= 8;

  return {
    ...state,
    mood: clamp(mood)
  };
}

export function createPetStateEngine(
  initial?: Partial<PetState>,
  options?: Partial<EngineOptions>
): PetStateEngine {
  const config = { ...DEFAULT_OPTIONS, ...options };
  let state: PetState = {
    ...createDefaultPetState(),
    ...initial,
    updatedAt: new Date().toISOString()
  };
  let lastTick = Date.now();

  const writeState = (next: Partial<PetState>): PetState => {
    state = {
      ...state,
      ...next,
      level: levelFromExp(next.exp ?? state.exp),
      hunger: clamp(next.hunger ?? state.hunger),
      mood: clamp(next.mood ?? state.mood),
      energy: clamp(next.energy ?? state.energy),
      affection: clamp(next.affection ?? state.affection),
      updatedAt: new Date().toISOString()
    };

    state = reduceMoodByNeeds(state);
    return state;
  };

  const tick = (now = new Date()): PetState => {
    const elapsedMs = Math.max(0, now.getTime() - lastTick);
    lastTick = now.getTime();

    const elapsedMinutes = elapsedMs / 60000;
    return writeState({
      hunger: state.hunger - config.hungerDecayPerMinute * elapsedMinutes,
      energy: state.energy - config.energyDecayPerMinute * elapsedMinutes,
      mood: state.mood - config.moodDecayPerMinute * elapsedMinutes
    });
  };

  const applyOpenClaw = (snapshot: OpenClawSnapshot): PetState => {
    tick();

    const busyPenalty = snapshot.agentState === "tool_running" ? 3 : 0;
    const errorPenalty = snapshot.agentState === "error" ? 8 : 0;
    const completeBonus = snapshot.agentState === "task_completed" ? 12 : 0;

    return writeState({
      animation: animationFromOpenClaw(snapshot),
      energy: state.energy - busyPenalty,
      mood: state.mood - errorPenalty + completeBonus,
      exp: state.exp + (completeBonus > 0 ? 15 : 2)
    });
  };

  const feed = (amount = 18): PetState => {
    tick();

    return writeState({
      hunger: state.hunger + amount,
      mood: state.mood + 6,
      exp: state.exp + 4,
      animation: "eat_snack"
    });
  };

  const pat = (amount = 10): PetState => {
    tick();

    return writeState({
      affection: state.affection + amount,
      mood: state.mood + 8,
      exp: state.exp + 3,
      animation: "happy_bounce"
    });
  };

  return {
    getState: () => state,
    tick,
    applyOpenClaw,
    feed,
    pat
  };
}
