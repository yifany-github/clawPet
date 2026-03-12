# Web Widget Prototype

Y2K 透明电子宠物 UI 的工程化原型，已接入 `openclaw-bridge`：

- 状态类映射：`idle/thinking/tool_running/error/offline/task_completed`
- WS 实时订阅：`/ws`
- 互动按钮：
  - `A` => `POST /api/pet/feed`
  - `B` => `POST /api/pet/pat`
  - `C` => 切换状态气泡文案
- D-Pad => 手动刷新 `GET /api/status`

## 运行

1. 启动 bridge

```bash
npm run dev:bridge
```

2. 启动静态文件服务器

```bash
cd apps/mac-pet-widget/web-widget-prototype
python3 -m http.server 8080
```

3. 打开页面

- 默认 bridge: `http://127.0.0.1:8787`
- 自定义 bridge:
  `http://127.0.0.1:8080/?bridge=http://127.0.0.1:8787`
