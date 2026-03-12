# OpenClaw 集成策略

## 第一阶段策略

- 以 CLI 采集为主：`openclaw status --all --json`。
- Bridge 做标准化输出，不把 OpenClaw 原始输出透传到客户端。
- 客户端只消费 `MergedStatus` 与事件流。

## 采集字段优先级

高优先级：

- `gatewayOnline`
- `agentState`
- `summary`

中优先级：

- `toolName`
- `lastCompleted`

低优先级：

- `usage`

## 安全边界

- OpenClaw Host 不直接暴露公网。
- 推荐通过 loopback/SSH tunnel/Tailscale 访问 Bridge。
- Bridge 默认只读；执行类接口必须 allowlist。
