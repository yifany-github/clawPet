# 架构说明

## 总览

```text
[Mac mini / OpenClaw Host]
        |
        | CLI status + logs
        v
[openclaw-bridge]
  - poller (CLI)
  - normalizer
  - pet-state-engine
  - REST + WebSocket
        |
   +----+----+
   |         |
   v         v
[mac-pet-widget] [mobile-companion]
```

## 设计原则

- OpenClaw 是事件源，宠物系统是上层 companion UI。
- Bridge 做协议隔离，客户端不直连 OpenClaw 内部细节。
- 宠物成长数据与 OpenClaw 状态解耦，保证长期可演进。
- 跨端共享统一数据模型（`packages/shared-types`）。

## 分层

- `packages/shared-types`: 共享状态对象与事件定义。
- `packages/pet-state-engine`: 宠物数值衰减、互动增益、动画状态机。
- `services/openclaw-bridge`: OpenClaw 采集 + 标准化事件 + API。
- `apps/mac-pet-widget`: 桌面浮窗、动画层、互动层、设置页。
- `apps/mobile-companion`: 第二阶段移动端同步与通知。

## 关键状态流

1. Bridge 轮询 OpenClaw CLI。
2. 解析得到 `OpenClawSnapshot`。
3. 输入 `pet-state-engine` 计算宠物状态。
4. 生成 `MergedStatus`。
5. 通过 REST 查询或 WS 推送给前端。
