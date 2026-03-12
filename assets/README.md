# Asset Pipeline

按 PRD 约定，资源目录应拆层管理，不把动态文案烘焙进底图。

结构：

- `ui/`：按钮、面板、气泡
- `pet/idle|work|error/`：逐帧或 sprite 切图
- `scene/`：背景、装饰
- `anim/`：动画配置 JSON
