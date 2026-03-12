import Fastify from "fastify";
import cors from "@fastify/cors";
import websocket from "@fastify/websocket";
import {
  createDefaultMergedStatus,
  type MergedStatus,
  type OpenClawSnapshot,
  type StatusEvent
} from "@clawpet/shared-types";
import { createPetStateEngine } from "@clawpet/pet-state-engine";
import { readConfig } from "./config";
import { OpenClawCliAdapter } from "./adapters/openclawCli";

function buildStatusEvent(type: StatusEvent["type"], payload: MergedStatus): StatusEvent {
  return {
    type,
    payload,
    timestamp: new Date().toISOString()
  };
}

async function start(): Promise<void> {
  const config = readConfig();
  const app = Fastify({ logger: true });

  await app.register(cors, { origin: true });
  await app.register(websocket);

  const petEngine = createPetStateEngine();
  const openclaw = new OpenClawCliAdapter(config.openclawBin);
  let status: MergedStatus = createDefaultMergedStatus();
  const subscribers = new Set<{ send: (text: string) => void }>();

  const publish = (event: StatusEvent): void => {
    const text = JSON.stringify(event);
    for (const client of subscribers) {
      try {
        client.send(text);
      } catch {
        subscribers.delete(client);
      }
    }
  };

  const updateFromOpenClaw = (snapshot: OpenClawSnapshot): void => {
    const pet = petEngine.applyOpenClaw(snapshot);

    status = {
      ...status,
      openclaw: snapshot,
      pet
    };

    publish(buildStatusEvent("openclaw.updated", status));
  };

  const poll = async (): Promise<void> => {
    const snapshot = await openclaw.readSnapshot();

    if (!snapshot.online && config.enableMockSource) {
      const mockSnapshot: OpenClawSnapshot = {
        online: true,
        agentState: "idle",
        summary: "Mock source enabled: waiting for real OpenClaw host",
        updatedAt: new Date().toISOString()
      };
      updateFromOpenClaw(mockSnapshot);
      return;
    }

    updateFromOpenClaw(snapshot);
  };

  app.get("/health", async () => ({ ok: true, service: "openclaw-bridge" }));

  app.get("/api/status", async () => status);

  app.get("/api/pet", async () => status.pet);

  app.post<{ Body: { amount?: number } }>("/api/pet/feed", async (request) => {
    const pet = petEngine.feed(request.body?.amount);
    status = { ...status, pet };
    const event = buildStatusEvent("pet.interacted", status);
    publish(event);
    return pet;
  });

  app.post<{ Body: { amount?: number } }>("/api/pet/pat", async (request) => {
    const pet = petEngine.pat(request.body?.amount);
    status = { ...status, pet };
    const event = buildStatusEvent("pet.interacted", status);
    publish(event);
    return pet;
  });

  app.get(
    "/ws",
    { websocket: true },
    (socket) => {
      const client = { send: (text: string) => socket.send(text) };
      subscribers.add(client);

      socket.send(JSON.stringify(buildStatusEvent("system.info", status)));

      socket.on("close", () => {
        subscribers.delete(client);
      });
    }
  );

  setInterval(() => {
    void poll();
  }, config.pollIntervalMs);

  await poll();

  await app.listen({ port: config.port, host: "0.0.0.0" });
}

void start();
