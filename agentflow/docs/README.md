# Lang AgentFlow Kit 内部说明

安装、profile 对比、工作流说明、subagent 数量建议、Superpowers 映射和 Oh My Codex adapter 指南，请查看根目录 `README.md`。

## 架构摘要

Lang AgentFlow Kit 由四层组合而成：

- spec-kit 风格的规格产物：`spec.md`、`plan.md`、`tasks.md`
- 面向长任务的 subagent-first 实现编排
- Superpowers-style 的角色方法，用于计划、审查、测试和修复
- 用于 dispatch、completion、review 和 archive 的项目 records

稳定合同是 `features/FEATURE-XXX-*` 下的 Feature Bundle。只要 provider 读取和写入该 bundle 以及 `project-docs/records/`，底层 provider 就可以替换。
