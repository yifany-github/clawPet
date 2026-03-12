export interface BridgeConfig {
  port: number;
  pollIntervalMs: number;
  openclawBin: string;
  enableMockSource: boolean;
}

function parseBool(value: string | undefined, fallback: boolean): boolean {
  if (!value) return fallback;
  return ["1", "true", "yes", "on"].includes(value.toLowerCase());
}

export function readConfig(): BridgeConfig {
  return {
    port: Number(process.env.PORT ?? 8787),
    pollIntervalMs: Number(process.env.POLL_INTERVAL_MS ?? 3000),
    openclawBin: process.env.OPENCLAW_BIN ?? "openclaw",
    enableMockSource: parseBool(process.env.ENABLE_MOCK_SOURCE, true)
  };
}
