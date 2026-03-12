import { describe, expect, test } from "vitest";
import { createPetStateEngine } from "../src";

describe("pet-state-engine", () => {
  test("maps openclaw tool_running to work animation", () => {
    const engine = createPetStateEngine();
    const state = engine.applyOpenClaw({
      online: true,
      agentState: "tool_running",
      toolName: "gmail.search",
      updatedAt: new Date().toISOString()
    });

    expect(state.animation).toBe("work_typing");
  });

  test("feed interaction improves hunger and mood", () => {
    const engine = createPetStateEngine({ hunger: 50, mood: 20 });
    const state = engine.feed(20);

    expect(state.hunger).toBeGreaterThan(50);
    expect(state.mood).toBeGreaterThan(20);
  });
});
