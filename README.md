# ClawPet Monorepo

根据《OpenClaw_桌面拓麻歌子挂件_PRD_技术说明》初始化的开发仓库。

## 目标

在另一台 Mac 上运行桌面宠物挂件，展示并同步 OpenClaw 状态；同时预留移动端同步能力。

## Monorepo 结构

```
apps/
  mac-pet-widget/         # macOS 桌面挂件（SwiftUI + AppKit）
  mobile-companion/       # 手机端（React Native / Expo，第二阶段）
services/
  openclaw-bridge/        # Bridge Service（Fastify + WebSocket）
packages/
  shared-types/           # 跨端共享类型
  pet-state-engine/       # 宠物状态引擎
assets/
  ui/ pet/ scene/ anim/   # 切图、逐帧、动画配置
docs/                     # 架构/API/开发计划/实施文档
```

## 当前已实现

- `@clawpet/shared-types`：OpenClaw/Pet/UI 合并状态模型。
- `@clawpet/pet-state-engine`：时间衰减、状态映射、喂食/抚摸互动、经验等级。
- `@clawpet/openclaw-bridge`：
  - `GET /health`
  - `GET /api/status`
  - `GET /api/pet`
  - `POST /api/pet/feed`
  - `POST /api/pet/pat`
  - `WS /ws`
  - OpenClaw CLI 轮询适配器（`openclaw status --all --json`）
- `apps/mac-pet-widget/web-widget-prototype`：可联调 bridge 的 Y2K UI 原型（状态映射 + WS + 按钮交互）
- `apps/mac-pet-widget`：可运行的 macOS 桌面挂件（SwiftUI + AppKit 浮窗，原生绘制 UI）

## 快速开始

1. 安装依赖

```bash
npm install
```

2. 启动 Bridge

```bash
npm run dev:bridge
```

3. 检查状态

```bash
curl http://localhost:8787/health
curl http://localhost:8787/api/status
```

## 文档索引

- [架构说明](./docs/architecture.md)
- [API 合同](./docs/api-contract.md)
- [开发计划](./docs/development-plan.md)
- [本地开发说明](./docs/local-setup.md)
- [OpenClaw 集成策略](./docs/openclaw-integration.md)
- [实施清单与验收对照](./docs/implementation-checklist.md)

## 下一步建议

- 对接真实 OpenClaw `logs --follow` 事件流，补全 `task_completed` 触发。
- 在 `apps/mac-pet-widget` 完成透明浮窗、拖拽、WS 订阅与资源加载。
- 增加持久化存储（宠物存档、用户偏好）和集成测试。
