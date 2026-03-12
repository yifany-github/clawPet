# 本地开发说明

## 环境

- Node.js >= 20
- npm >= 10
- macOS（开发桌面端时）

## 安装

```bash
npm install
```

## 启动 Bridge

```bash
npm run dev:bridge
```

默认端口：`8787`

可选环境变量（`services/openclaw-bridge/.env.example`）：

- `PORT`
- `POLL_INTERVAL_MS`
- `OPENCLAW_BIN`
- `ENABLE_MOCK_SOURCE`

## 构建与测试

```bash
npm run build
npm run test
npm run typecheck
```
