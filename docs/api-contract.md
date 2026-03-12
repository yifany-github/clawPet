# API 合同（Bridge Service）

Base URL: `http://localhost:8787`

## `GET /health`

服务健康检查。

Response:

```json
{
  "ok": true,
  "service": "openclaw-bridge"
}
```

## `GET /api/status`

返回合并状态（OpenClaw + Pet + UI）。

## `GET /api/pet`

返回当前宠物状态。

## `POST /api/pet/feed`

喂食互动。

Body:

```json
{
  "amount": 18
}
```

## `POST /api/pet/pat`

抚摸互动。

Body:

```json
{
  "amount": 10
}
```

## `WS /ws`

事件推送，消息结构：

```json
{
  "type": "openclaw.updated",
  "payload": {
    "pet": {},
    "openclaw": {},
    "ui": {}
  },
  "timestamp": "2026-03-11T19:10:00.000Z"
}
```
