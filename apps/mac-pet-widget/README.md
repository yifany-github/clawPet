# mac-pet-widget

第一阶段目标：macOS 常驻桌面宠物挂件（SwiftUI + AppKit）。

## MVP 功能

- 无边框透明浮窗
- Always-on-top
- 拖拽定位
- WebSocket 订阅 `openclaw-bridge`
- 宠物动画切换（idle/thinking/work/error/offline）
- 互动按钮（喂食、抚摸）

## 目录建议

- `Sources/MacPetWidgetApp/App.swift`：入口
- `Sources/MacPetWidgetApp/Window/FloatingPanelController.swift`：浮窗封装
- `Sources/MacPetWidgetApp/Views/PetView.swift`：宠物展示层
- `Sources/MacPetWidgetApp/Services/BridgeClient.swift`：REST/WS 客户端
- `Sources/MacPetWidgetApp/Services/AssetLoader.swift`：资源加载

## Web 原型

已提供可直接联调 bridge 的 UI 原型：

- `web-widget-prototype/index.html`
- `web-widget-prototype/styles.css`
- `web-widget-prototype/app.js`
- `web-widget-prototype/README.md`
