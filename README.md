# nursing_nani_app

护工执行端与 AI 协同原型工程。

## 当前范围

- Flutter 3 工程，使用 GetX 负责路由、依赖注入和页面状态。
- 所有页面统一采用 GetView。
- 页面按小组件拆分，先用 Mock 服务承接护工端 MVP 闭环。
- 已覆盖首页总览、任务中心、报警处理、AI 护理助手、我的班次。
- 已补充次级页面：重点长者、健康录入、护理执行、交接班、排班。
- 已补充登录页、路由鉴权、首页消息中心和报警详情时间线。

## 设计依据

本工程实现对齐 nursing-documents 中的以下文档：

- requirements/project-overview.md
- requirements/staff-collaboration.md
- requirements/health-monitoring.md
- requirements/alerts-incidents.md
- requirements/ai-operations-center.md
- platform/MODULE_PAGE_MAPPING.md
- platform/IMPLEMENTATION_BLUEPRINT.md

## 运行方式

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## 工程结构

```text
lib/
  app/
    data/          # Mock 模型与服务
    middleware/    # 路由鉴权
    modules/       # GetView 页面模块
    routes/        # GetX 路由定义
    theme/         # 色板、渐变与 ThemeData
    widgets/       # 公共小组件
```

## 后续接入建议

1. 把 MockNaniService 替换为 BFF / API Repository。
2. 将 AuthService 替换为真实认证与 token 刷新机制。
3. 为健康录入和护理执行页接入真实提交链路。
4. 在 AI 助手页补充对象上下文透传和审计日志入口。
5. 把报警处理与交接班联动到正式责任人和时间线服务。

## Harness 交付模板

本地 docs Markdown 已迁移到 nursing-documents 统一管理。

后续任务页、报警流、登录鉴权和交接班相关改动，默认先按 ../nursing-documents/docs/ui/nani-delivery/frontend-delivery-template.md 补齐范围、用户影响、数据来源、UI 状态、健康信号、验证门禁和回滚路径，再进入实现。

已完成的本地交付入口索引见 ../nursing-documents/docs/ui/nani-delivery/index.md
