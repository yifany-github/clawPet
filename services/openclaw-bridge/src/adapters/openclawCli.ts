import { execFile as execFileCb } from "node:child_process";
import { promisify } from "node:util";
import type { AgentState, OpenClawSnapshot } from "@clawpet/shared-types";

const execFile = promisify(execFileCb);

function inferAgentState(text: string): AgentState {
  const normalized = text.toLowerCase();

  if (normalized.includes("error") || normalized.includes("failed")) return "error";
  if (normalized.includes("tool_running") || normalized.includes("running")) return "tool_running";
  if (normalized.includes("thinking")) return "thinking";
  if (normalized.includes("completed") || normalized.includes("done")) return "task_completed";
  if (normalized.includes("idle")) return "idle";

  return "idle";
}

function tryParseJson(stdout: string): Partial<OpenClawSnapshot> | null {
  try {
    const parsed = JSON.parse(stdout) as Record<string, unknown>;

    return {
      online: Boolean(parsed.online ?? parsed.gatewayOnline ?? true),
      agentState: inferAgentState(String(parsed.agentState ?? parsed.state ?? "idle")),
      toolName: parsed.toolName ? String(parsed.toolName) : undefined,
      summary: parsed.summary ? String(parsed.summary) : undefined,
      lastCompleted: parsed.lastCompleted ? String(parsed.lastCompleted) : undefined,
      usage: parsed.usage ? JSON.stringify(parsed.usage) : undefined
    };
  } catch {
    return null;
  }
}

export class OpenClawCliAdapter {
  constructor(private readonly openclawBin: string) {}

  async readSnapshot(): Promise<OpenClawSnapshot> {
    try {
      const { stdout } = await execFile(this.openclawBin, ["status", "--all", "--json"], {
        timeout: 4000
      });

      const parsed = tryParseJson(stdout);

      if (parsed) {
        return {
          online: parsed.online ?? true,
          agentState: parsed.agentState ?? "idle",
          toolName: parsed.toolName,
          summary: parsed.summary,
          lastCompleted: parsed.lastCompleted,
          usage: parsed.usage,
          updatedAt: new Date().toISOString()
        };
      }

      return {
        online: true,
        agentState: inferAgentState(stdout),
        summary: stdout.trim().slice(0, 120),
        updatedAt: new Date().toISOString()
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : "openclaw cli unavailable";

      return {
        online: false,
        agentState: "offline",
        summary: message,
        updatedAt: new Date().toISOString()
      };
    }
  }
}
