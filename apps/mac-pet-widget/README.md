# mac-pet-widget

macOS 桌面挂件（SwiftUI + AppKit，纯原生实现）。

## 特性

- 无边框透明浮窗
- Always on top（悬浮）
- 可拖拽移动（拖背景即可）
- 原生绘制拓麻歌子外壳、屏幕、按键
- Bridge 实时联动（状态显示 + 喂食/抚摸）
- 设置页支持修改 Bridge URL

## 运行

1. 启动 bridge（仓库根目录）

```bash
npm run dev:bridge
```

2. 启动 mac 挂件

```bash
cd apps/mac-pet-widget
swift run MacPetWidgetApp
```

## 代码结构

- `AppEntry.swift`：应用入口、窗口样式
- `BridgeModels.swift`：Bridge 数据模型
- `BridgeStore.swift`：WS/REST 状态管理
- `WidgetView.swift`：原生挂件 UI + 设置面板

## 网页原型（开发目录）

- `web-widget-prototype/index.html`
- `web-widget-prototype/styles.css`
- `web-widget-prototype/app.js`
