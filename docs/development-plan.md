# 分阶段开发计划

## Phase 1（1-2 周）

目标：可用 MVP。

交付：

- Bridge Service 可运行，支持状态查询与 WS 推送。
- macOS 挂件可显示在线/离线、busy/idle。
- 至少 4 个动画状态（idle/thinking/work/error）。
- 至少 2 个互动（feed/pat）。

## Phase 2（1 周）

目标：剧情化同步。

交付：

- 工具动作映射细化（`toolName -> animation`）。
- 完成任务反馈（`task_completed`）与经验成长。
- 增加异常恢复和降级策略。

## Phase 3（1-2 周）

目标：手机端同步。

交付：

- 移动端基础页面与状态同步。
- 远程互动与通知。
- 宠物存档跨端同步。
