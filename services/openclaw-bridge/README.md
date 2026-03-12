# openclaw-bridge

OpenClaw 与各客户端之间的协议桥接服务。

## 功能

- 轮询 OpenClaw CLI（默认：`openclaw status --all --json`）
- 标准化为统一 `MergedStatus`
- 对外提供 REST + WebSocket
- 集成宠物状态引擎

## 运行

```bash
npm install
npm run dev --workspace @clawpet/openclaw-bridge
```

## 环境变量

参考 `.env.example`。
