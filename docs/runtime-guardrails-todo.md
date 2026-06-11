# Runtime Guardrails TODO

## 目标

把 Lang AgentFlow Kit 从 Markdown-only 工作流合同，推进为带轻量 runtime guardrails 的协议引擎。

目标不是“支持所有编码场景”。

目标是：

- 长期 AI 辅助软件项目
- 多阶段交接的复杂 feature
- 减少上下文漂移和协议遗忘
- 在不替代 Markdown 工作流的前提下，加强阶段约束

## 范围

保留：

- `AGENTS.md`
- `project-docs/`
- Feature Bundle contracts
- 自然语言和 Markdown 协作

新增：

- runtime verification
- stage gates
- active context state
- optional hooks
- 更清晰的 complexity profiles

暂不做：

- 完整外部 orchestrator runtime
- 自动执行 spec-kit
- 重型 daemon 或服务架构
- 用数据库或 UI-first workflow 替代 Markdown

## Phase 0: 定位和合同清理

- [x] 重写根 `README.md`，围绕复杂、长期 AI 项目重新定位。
- [x] 明确非目标：小修补、一次性脚本、快速 vibe coding。
- [x] 说明当前稳定资产是 Feature Bundle contract 和 records contract。
- [x] 说明 protocol constraints 与 runtime constraints 的区别。
- [x] 添加“Markdown contract + lightweight runtime guardrails”的简短架构说明。

## Phase 1: 配置 Schema 升级

- [x] 扩展 `agentflow.config.yml`，暂不立即迁移配置路径。
- [x] 添加 `complexity_profile` 支持。当前模板值：`standard`。
- [ ] 添加显式 `stages` 配置。延后到 v1 global gate model 被证明不够用之后。
- [x] 记录 structured per-stage `gates` 作为未来 schema 方向，同时保留当前全局 gate flags。
- [x] 添加 `state` 配置，用于生成 runtime state files。
- [x] 添加 `hooks` 配置，用于可选 stage commands。
- [x] 保持与现有 `lite / standard / full` 模板兼容。
- [ ] 等新 schema 稳定后再定义迁移路径。

## Phase 2: 阶段模型

- [x] 在 CLI 行为中定义 canonical stage order。
- [x] 通过 `gate` 定义阶段进入条件。
- [x] 通过 `verify` 定义阶段完成条件。
- [x] 在 `README.md` 和 `docs/config-schema.md` 中定义 mandatory vs optional stage outputs。
- [x] 决定第一版 human-reviewable vs machine-verifiable 策略：review 文件仍由人编写，runtime 验证其结构完成度。

推荐第一版阶段：

- `spec`
- `plan`
- `tasks`
- `dispatch`
- `implement`
- `test`
- `review`
- `fix`
- `archive`

## Phase 3: `agentflow verify`

- [x] 添加 `agentflow verify FEATURE-XXX --stage <stage>`。
- [x] 添加日常 namespace alias：`agentflow feature verify FEATURE-XXX --stage <stage>`。
- [x] 验证某阶段所需文件存在。
- [x] 验证明显占位符如 `TBD` 或原始模板残留已移除。
- [x] 在要求时验证 review checklist sections 已完成。
- [x] 在要求时验证 archive/test/review records 存在。
- [x] 返回清晰失败信息，告诉用户缺少什么。
- [x] 第一版保持 rule-based 和 deterministic。

第一版验证规则：

- `spec`：`spec.md` 存在、无 open placeholders、`spec-review.md` gate completed。
- `plan`：`plan.md` 存在、依赖已通过的 `spec`、`plan-review.md` gate completed。
- `tasks`：`tasks.md` 存在、依赖已通过的 `plan`、`task-review.md` gate completed。
- `dispatch`：`dispatch.md` 存在，且有 task ownership rows。
- `archive`：`archive.md` 存在，并引用 implementation、test 和 review outputs。

## Phase 4: `agentflow gate`

- [x] 添加 `agentflow gate FEATURE-XXX --to <stage>`。
- [x] 添加日常 namespace alias：`agentflow feature gate FEATURE-XXX --to <stage>`。
- [x] 当前置阶段验证失败时阻止 transition。
- [x] 让 gate 输出同时适合人和 agent 阅读。
- [x] 复用 `verify` 逻辑，避免重复检查。
- [x] 决定 `dispatch` 和 `archive` 是否默认 hard-fail unmet gates。当前配置默认：`enforce_dispatch_gate: true`、`enforce_archive_gate: true`。

推荐第一批 hard gates：

- [x] 进入 `plan` 前阻止未通过的 `spec`。
- [x] 进入 `tasks` 前阻止未通过的 `plan`。
- [x] 进入 `dispatch` 前阻止未通过的 `tasks`。
- [x] 进入 `archive` 前阻止缺失的 test/review artifacts。

## Phase 5: Runtime State 和 `agentflow context`

- [x] 添加 `.agentflow/state/` 作为生成 runtime state output。
- [x] 添加 `agentflow context FEATURE-XXX`。
- [x] 添加日常 namespace alias：`agentflow feature context FEATURE-XXX`。
- [x] 生成 `.agentflow/state/active_context.json`。
- [x] 文件从 Markdown 生成，永远不手工维护。
- [x] 包含 current feature、current stage、next gate、open tasks 和 key files。
- [x] JSON 保持刻意简短，便于 agent 低成本消费。

active context 应回答：

- 我正在做什么？
- 我处于哪个阶段？
- 进入下一步前必须满足什么？
- 现在哪些文件重要？
- 下一个阻塞动作是什么？

## Phase 6: Hook System

- [x] 在配置中支持 optional stage hooks。
- [x] 在配置中添加 before/after stage hook keys。
- [x] 允许测试、lint、`agentflow verify` 等命令。
- [x] 通过 `runtime.hook_failure_policy` 定义 hook failure behavior。
- [x] 确保 hooks 是可选的，让 CLI 保持轻量。

示例形状：

```yaml
hooks:
  after_plan:
    - agentflow verify FEATURE-001-demo --stage plan
  after_implement:
    - npm test
    - agentflow verify FEATURE-001-demo --stage implement
```

## Phase 7: Git Hygiene

- [x] 区分 durable project knowledge 和高频 runtime state。
- [x] 默认将 architecture/spec/plan/tasks/archive 放进 Git。
- [x] 将 transient runtime artifacts 移到 `.agentflow/state/` 下。
- [x] 决定 `project-docs/records/dispatch/` 是 durable 还是 transient。默认策略：除非项目需要完整审计轨迹，否则视为 transient。
- [x] 为 generated runtime state 添加推荐 `.gitignore` 指引。

## Phase 8: Template 和 Prompt 对齐

- [x] 更新 `AGENTS.md` 模板，让 agent 使用 runtime commands。
- [x] 更新 Manager 角色说明，依赖 CLI gate checks，而不是只依赖记忆。
- [x] 更新 feature templates，让 checklist completion 可被机器检查。
- [x] 移除暗示 workflow 纯靠纪律执行的语言。

## Phase 9: 文档和示例

- [x] 在 `README.md` 中添加 runtime guardrails section。
- [x] 添加 passing vs failing verify output 示例。
- [ ] 添加 strict project config 示例。延后到 per-stage schema 实现之后，因为 `complexity_profile: strict` 当前只是描述性的。
- [x] 添加已有 Markdown-only flow 用户的迁移说明。

## 实现顺序

1. [x] 更新 `README.md` 定位
2. [x] 扩展 config schema
3. [x] 在 CLI 行为中定义 stage model
4. [x] `agentflow verify`
5. [x] `agentflow gate`
6. [x] `agentflow context`
7. [x] Hook support
8. [x] Git hygiene 和 template cleanup

## 近期任务

- [x] 确认第一个 milestone 只覆盖 `verify`、`gate` 和 `context`。
- [x] 决定第一批支持 hard enforcement 的 stages。
- [x] 决定 `dispatch` 在 v1 中立即 hard-fail 还是保持 soft。当前默认是 hard-fail。
- [x] 决定 runtime state 是否在本 demo repo 中提交到 Git。当前 `.gitignore` 策略排除 `.agentflow/state/`。

## 当前 Runtime 状态

2026-05-27 使用 `bin/agentflow feature status` 检查：

| Feature | Runtime Stage | Next Gate | Progress | Status |
| --- | --- | --- | --- | --- |
| `FEATURE-001-feature` | `draft` | `plan` | 0% | blocked: spec placeholders and pending spec review |
| `FEATURE-002-feature` | `draft` | `plan` | 0% | blocked: spec placeholders and pending spec review |

## 优化 Backlog

- [x] 在 `bin/agentflow` 之外记录 stage model，让用户不用读 shell code 也能理解合同。
- [x] 决定 `gates:` 保持全局 booleans 还是改成 per-stage structured rules。决定：v1 保持全局 booleans；将 per-stage rules 记录为未来 schema。
- [x] 为 `feature verify`、`feature gate`、`feature status` 和 `feature next` 添加 passing/failing 示例。
- [x] 说明 records policy：哪些 records 是 durable project history，哪些是 transient runtime artifacts。
- [x] 收紧 Manager 和角色说明，让 agent 使用 runtime commands 作为事实来源。
- [ ] schema 稳定后添加 strict config 示例。
- [x] 添加 runtime guardrails 之前初始化项目的迁移指引。

## 下一阶段加固路线图

下一阶段优化跟踪在：

- [next-stage-hardening-roadmap.md](./next-stage-hardening-roadmap.md)

优先级：

1. YAML-driven execution
2. Gate system hardening
3. Active context hardening
4. State-backed board rendering
5. Review isolation
6. Optional small engine extraction
