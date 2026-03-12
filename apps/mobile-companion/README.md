# mobile-companion

第二阶段目标：iPhone companion 应用，与桌面端共享同一宠物存档。

## 计划功能

- 展示宠物基础状态与成长数值
- 远程喂食、抚摸
- 接收任务完成/离线/错误通知
- 同步最近任务摘要

## 技术路线

- React Native + Expo
- 复用 `packages/shared-types`
- 通过 `openclaw-bridge` REST + WS 通讯
