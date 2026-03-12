const STATE_CLASSES = [
  "state-idle",
  "state-thinking",
  "state-tool_running",
  "state-error",
  "state-offline",
  "state-task_completed"
];

const DEFAULT_BRIDGE = "http://127.0.0.1:8787";

const els = {
  widget: document.querySelector("#widget"),
  hearts: document.querySelector("#hud-hearts"),
  onlineIndicator: document.querySelector("#online-indicator"),
  agentIndicator: document.querySelector("#agent-indicator"),
  statusRibbon: document.querySelector("#status-ribbon"),
  poop: document.querySelector("#poop-sprite"),
  bridgeUrl: document.querySelector("#bridge-url"),
  openclawState: document.querySelector("#openclaw-state"),
  toolName: document.querySelector("#tool-name"),
  petStats: document.querySelector("#pet-stats"),
  updatedAt: document.querySelector("#updated-at"),
  refreshButton: document.querySelector("#refresh-button"),
  feedButton: document.querySelector("#feed-button"),
  patButton: document.querySelector("#pat-button"),
  bubbleButton: document.querySelector("#bubble-button")
};

const urlParams = new URLSearchParams(window.location.search);
const bridgeParam = urlParams.get("bridge");
const bridgeBaseUrl = (bridgeParam || localStorage.getItem("clawpet_bridge") || DEFAULT_BRIDGE).replace(/\/$/, "");
localStorage.setItem("clawpet_bridge", bridgeBaseUrl);
els.bridgeUrl.textContent = bridgeBaseUrl;

let ws;
let reconnectTimer;
let bubbleEnabled = true;
let latestStatus = null;

function setAgentStateClass(agentState) {
  for (const className of STATE_CLASSES) {
    els.widget.classList.remove(className);
  }

  const safeState = STATE_CLASSES.includes(`state-${agentState}`) ? agentState : "idle";
  els.widget.classList.add(`state-${safeState}`);
}

function renderHearts(mood = 0) {
  const count = mood >= 75 ? 3 : mood >= 45 ? 2 : mood >= 20 ? 1 : 0;
  els.hearts.textContent = "";

  for (let i = 0; i < 3; i += 1) {
    const heart = document.createElement("div");
    heart.className = `pixel-heart ${i < count ? "full" : ""}`.trim();
    els.hearts.appendChild(heart);
  }
}

function humanTime(iso) {
  if (!iso) return "-";

  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return iso;
  return `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`;
}

function buildRibbonText(status) {
  const openclaw = status?.openclaw;
  const pet = status?.pet;

  if (!bubbleEnabled) {
    return `LV ${pet?.level ?? 1} | Mood ${pet?.mood ?? 0} | Hunger ${pet?.hunger ?? 0}`;
  }

  if (!openclaw?.online) {
    return "OpenClaw offline - waiting for bridge";
  }

  if (openclaw.summary) {
    return openclaw.summary;
  }

  return `Agent: ${openclaw.agentState || "idle"}`;
}

function applyStatus(status, source = "ws") {
  latestStatus = status;

  const openclaw = status.openclaw || {};
  const pet = status.pet || {};

  setAgentStateClass(openclaw.agentState || "idle");
  renderHearts(pet.mood || 0);

  els.onlineIndicator.classList.toggle("active", Boolean(openclaw.online));
  els.agentIndicator.classList.toggle("active", openclaw.agentState === "tool_running" || openclaw.agentState === "thinking");

  els.statusRibbon.textContent = buildRibbonText(status);
  els.poop.classList.toggle("visible", (pet.hunger ?? 0) < 28);

  els.openclawState.textContent = `${openclaw.online ? "online" : "offline"} / ${openclaw.agentState || "unknown"}`;
  els.toolName.textContent = openclaw.toolName || "-";
  els.petStats.textContent = `L${pet.level ?? 1} | hunger ${pet.hunger ?? 0} | mood ${pet.mood ?? 0} | energy ${pet.energy ?? 0} | aff ${pet.affection ?? 0}`;
  els.updatedAt.textContent = `${humanTime(status.openclaw?.updatedAt || status.pet?.updatedAt)} (${source})`;
}

async function request(path, options = {}) {
  const response = await fetch(`${bridgeBaseUrl}${path}`, {
    headers: {
      "Content-Type": "application/json"
    },
    ...options
  });

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }

  return response.json();
}

async function refreshStatus(source = "http") {
  try {
    const status = await request("/api/status");
    applyStatus(status, source);
  } catch (error) {
    els.statusRibbon.textContent = `Refresh failed: ${error instanceof Error ? error.message : "unknown"}`;
  }
}

async function interact(path) {
  try {
    const pet = await request(path, {
      method: "POST",
      body: JSON.stringify({})
    });

    if (!latestStatus) {
      await refreshStatus("http");
      return;
    }

    applyStatus({ ...latestStatus, pet }, "interaction");
  } catch (error) {
    els.statusRibbon.textContent = `Action failed: ${error instanceof Error ? error.message : "unknown"}`;
  }
}

function wsUrlFromHttp(httpUrl) {
  if (httpUrl.startsWith("https://")) return `wss://${httpUrl.slice(8)}/ws`;
  if (httpUrl.startsWith("http://")) return `ws://${httpUrl.slice(7)}/ws`;
  return `${httpUrl}/ws`;
}

function connectWs() {
  if (ws && ws.readyState === WebSocket.OPEN) {
    return;
  }

  clearTimeout(reconnectTimer);

  const wsUrl = wsUrlFromHttp(bridgeBaseUrl);
  ws = new WebSocket(wsUrl);

  ws.addEventListener("open", () => {
    els.onlineIndicator.classList.add("active");
    els.statusRibbon.textContent = "WebSocket connected";
  });

  ws.addEventListener("message", (event) => {
    try {
      const data = JSON.parse(event.data);
      if (!data.payload) return;
      applyStatus(data.payload, "ws");
    } catch {
      els.statusRibbon.textContent = "Invalid event payload";
    }
  });

  ws.addEventListener("close", () => {
    els.onlineIndicator.classList.remove("active");
    els.statusRibbon.textContent = "WebSocket closed - reconnecting...";
    reconnectTimer = setTimeout(connectWs, 1400);
  });

  ws.addEventListener("error", () => {
    els.statusRibbon.textContent = "WebSocket error";
  });
}

els.refreshButton.addEventListener("click", () => {
  refreshStatus("manual");
});

els.feedButton.addEventListener("click", () => {
  interact("/api/pet/feed");
});

els.patButton.addEventListener("click", () => {
  interact("/api/pet/pat");
});

els.bubbleButton.addEventListener("click", () => {
  bubbleEnabled = !bubbleEnabled;
  if (latestStatus) {
    els.statusRibbon.textContent = buildRibbonText(latestStatus);
  }
});

renderHearts(0);
refreshStatus("boot");
connectWs();
