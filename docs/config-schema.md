# AgentFlow 配置 Schema

本文档说明 Lang AgentFlow Kit 当前使用的 `agentflow.config.yml` 结构。

它有意区分两类字段：

- 当前 CLI runtime 会主动读取的字段
- 描述性 metadata 或面向 adapter 的配置字段

当前 runtime 很轻量，并**没有**实现完整 YAML schema engine。请保持配置简单。

## 示例

```yaml
version: 1
profile: standard
complexity_profile: standard

project:
  feature_dir: features
  docs_dir: project-docs

runtime:
  state_dir: .agentflow/state
  active_context_file: active_context.json
  active_context_markdown_file: active_context.md
  enforce_dispatch_gate: true
  enforce_archive_gate: true
  require_reuse_gate_for_sensitive: true
  hook_failure_policy: stop

workflow:
  default_type: standard

hooks:
  before_dispatch:
    - bin/agentflow feature status {{FEATURE}}
  after_plan:
    - bin/agentflow feature context {{FEATURE}}
  after_implement:
    - bin/agentflow feature verify {{FEATURE}} --stage implement

gates:
  require_spec_review: true
  require_plan_review: true
  require_task_review: true
  require_dispatch_record_for_archive: true
  require_summary_records_for_done: true
  require_tests_before_done: true
  require_review_before_commit: true

implementation:
  target_sides:
    - backend
    - frontend
    - mobile

external_module_policy:
  public_default_mode: reference-only
  public_vendor_allowed: false
  sensitive_domains:
    critical:
      - auth
      - user
      - permission
      - payment
      - crypto
      - file-upload
      - admin-account

external_modules:
  - id: public-admin-template
    source_type: public
    source: github:xxx/admin-template
    domain: auth
    risk_level: critical
    allowed_modes:
      - reference-only
    forbidden_modes:
      - vendor
      - direct-copy
```

## Runtime 会读取的字段

这些字段会被当前 `bin/agentflow` runtime 读取。

### 顶层字段

- `version`
  仅作为配置 metadata 使用。当前模板设置为 `1`。
- `profile`
  profile metadata，例如 `lite`、`standard` 或 `full`。
- `complexity_profile`
  面向人的复杂度标签，例如 `light`、`standard` 或 `strict`。

### `project`

- `project.feature_dir`
  默认值：`features`
  用于解析 feature bundle 目录。
- `project.docs_dir`
  默认值：`project-docs`
  用于解析 records、任务板和项目文档。

### `runtime`

- `runtime.state_dir`
  默认值：`.agentflow/state`
  生成 runtime state 的输出目录，例如 `active_context.json`。
- `runtime.active_context_file`
  默认值：`active_context.json`
  `agentflow feature context` 写入的 JSON 文件名。
- `runtime.active_context_markdown_file`
  默认值：`active_context.md`
  `agentflow feature context` 写入的 Markdown 文件名。推荐 agent 在开始工作前优先阅读该文件。
- `runtime.enforce_dispatch_gate`
  默认值：`true`
  如果为 true，`feature dispatch` 会先硬检查 `dispatch` gate。
- `runtime.enforce_archive_gate`
  默认值：`true`
  如果为 true，`feature archive` 会先硬检查 `archive` gate。
- `runtime.require_reuse_gate_for_sensitive`
  默认值：`true`
  如果为 true，sensitive workflow 必须在 plan/implementation 前通过 reuse gate。当前 runtime 也提供 `agentflow reuse analyze` 和 `agentflow reuse gate`，可手动用于任意 feature。
- `runtime.hook_failure_policy`
  默认值：`stop`
  控制 hook 失败行为。
  支持的值：
  - `stop`：hook 命令返回非零时立即失败
  - `warn`：打印 warning 并继续

### `hooks`

支持的 hook 字段：

- `hooks.before_plan`
- `hooks.before_tasks`
- `hooks.before_dispatch`
- `hooks.before_implement`
- `hooks.before_test`
- `hooks.before_review`
- `hooks.before_fix`
- `hooks.before_archive`
- `hooks.after_spec`
- `hooks.after_plan`
- `hooks.after_tasks`
- `hooks.after_dispatch`
- `hooks.after_implement`
- `hooks.after_test`
- `hooks.after_review`
- `hooks.after_fix`

每个 hook 的值应是简单 YAML list，元素为 shell command 字符串。

Hook 时机：

- `before_<stage>` 在 runtime 检查进入目标阶段前运行
- `after_<stage>` 在前一个阶段成功完成后运行

示例：

- `feature gate FEATURE-001-demo --to tasks` 可能触发 `before_tasks`，随后触发 `after_plan`
- `feature advance FEATURE-001-demo --to review` 可能触发 `before_review`，随后触发 `after_test`

hook 命令中支持的 token 展开：

- `{{FEATURE}}`
- `{{FEATURE_DIR}}`
- `{{PROJECT_ROOT}}`
- `{{STAGE}}`

### `gates`

当前 `gates:` 字段有意保持为全局 boolean。这样 v1 runtime 在 shell 中更简单、更易解析。

- `gates.require_spec_review`
  如果为 true，`spec` 被视为有效前，`spec-review.md` 必须通过。
- `gates.require_plan_review`
  如果为 true，`plan` 被视为有效前，`plan-review.md` 必须通过。
- `gates.require_task_review`
  如果为 true，`tasks` 被视为有效前，`task-review.md` 必须通过。
- `gates.require_dispatch_record_for_archive`
  如果为 true，`archive` 需要有效 dispatch record。
- `gates.require_summary_records_for_done`
  如果为 true，`done` 需要有效 review/test/done summary records。
- `gates.require_tests_before_done`
  如果为 true，后续阶段通过前，`implementation/test.md` 必须通过。
- `gates.require_review_before_commit`
  如果为 true，后续阶段通过前，`implementation/review.md` 必须通过。
- `gates.require_archive_before_done`
  当前在模板中是描述性字段。runtime 已经把 `done` 建模为严格位于 `archive` 之后，所以该字段目前实际上是冗余的。

### `implementation`

- `implementation.target_sides`
  默认值：`backend`、`frontend`、`mobile`
  runtime enforced 的实现结果侧列表。支持值为 `backend`、`frontend` 和 `mobile`。

  `agentflow feature create` 只会为配置过的 side 生成 `results/<side>.md`。`agentflow check`、`agentflow feature verify`、`agentflow feature gate` 和生成的 active context 也只要求这些 result 文件。

  backend-only 项目示例：

  ```yaml
  implementation:
    target_sides:
      - backend
  ```

  该项目不会生成或要求 `results/frontend.md` 或 `results/mobile.md`。

### `workflow`

- `workflow.default_type`
  默认值：`standard`
  当 `agentflow feature create` 省略 `--type` 时使用。

支持的 feature 类型和阶段列表：

```yaml
trivial:
  stages: [implement, archive]
bug:
  stages: [implement, test, archive]
standard:
  stages: [spec, plan, tasks, implement, test, archive]
major:
  stages: [spec, plan, tasks, dispatch, implement, test, review, fix, archive]
sensitive:
  stages: [spec, reuse-risk, plan, tasks, dispatch, implement, security-review, test, review, fix, archive]
```

没有 `state.yml` 或没有 `type` 的旧 feature bundle 会被视为 `major`，这样已有 0.5.0 项目在迁移或显式编辑前，会保留之前较重的 workflow。

### `external_module_policy`

外部模块治理的项目本地事实来源位于 `.agentflow/modules/`：

```text
.agentflow/modules/external_modules.yml
.agentflow/modules/external_module_policy.yml
.agentflow/modules/MODULE_ID/module-contract.yml
.agentflow/modules/MODULE_ID/security-notes.md
.agentflow/modules/MODULE_ID/integration-notes.md
```

当前 runtime 将其视为静态治理 metadata。它不会下载、vendor、复制或合并外部模块。

默认行为：

- 公共模块默认 `reference-only`。
- 除非人在自动流程之外明确批准例外，否则公共 vendor/direct-copy 被禁止。
- critical sensitive domains 包括 auth、user、permission、payment、crypto、file-upload 和 admin-account。

### `review`

当 review gate 启用时，runtime 会执行 review isolation。

支持的模式：

- `self`：当前 AI/session 可以审查自己的工作。它兼容早期项目，但会输出 weak-isolation warning。
- `separate-session`：review 文件必须包含外部 review metadata：

  ```yaml
  review_mode: separate-session
  reviewer: external
  decision: approved
  blocking_issues: 0
  reviewed_at: 2026-05-27
  ```

- `human`：必须由 CLI 写入人工批准：

  ```sh
  agentflow approve FEATURE-001-demo --stage spec
  ```

  该命令会写入：

  ```yaml
  approved_by: local-user
  approved_at: 2026-05-27T12:00:00
  approval_source: cli
  ```

配置形状：

```yaml
review:
  spec:
    mode: self
  plan:
    mode: self
  tasks:
    mode: self
  implementation:
    mode: self
```

未来版本可能会用 per-stage structured rules 替换或补充当前全局 boolean：

```yaml
stages:
  plan:
    requires:
      - spec
    outputs:
      - plan.md
      - plan-review.md
  archive:
    requires:
      - fix
      - test
      - review
    records:
      - dispatch
```

上面的示例是设计方向，不是当前 runtime 会消费的格式。

## Metadata / Adapter 字段

这些字段存在于模板中，对人或未来 adapter 有用，但当前本地 runtime 不强依赖它们。

### `spec`

示例：

- `spec.provider`
- `spec.source_dir`
- `spec.required_outputs`

当前用法：

- `spec.required_outputs` 在本地 runtime 中只是描述性字段。
- CLI 仍使用硬编码的阶段文件名做验证。

### `orchestrator`

示例：

- `orchestrator.provider`
- `orchestrator.mode`
- `orchestrator.fallback_provider`
- `orchestrator.default_mode`
- `orchestrator.long_task_default`

当前用法：

- 主要是描述性的。
- 有助于表达 adapter 意图，并保持 README 对齐。

### `skills`

示例：

- `skills.provider`
- `skills.vendored_superpowers`
- `skills.role_method_map.*`

当前用法：

- 对本地 runtime 只是描述性字段。
- init 流程仍根据所选 profile 复制 vendored skills。

### `integrations`

示例：

- `integrations.spec_kit.*`
- `integrations.oh_my_codex.*`

当前用法：

- 主要是 adapter metadata 和模板配置。
- 本地 runtime 不会直接执行它们。

### `archive`

示例：

- `archive.provider`
- `archive.records_dir`
- `archive.task_board`
- `archive.subagent_dir`

当前用法：

- 这些值当前是描述性的。
- runtime 通过 `project.docs_dir` 和内置约定解析路径。

## 阶段模型

当前 runtime 阶段顺序是：

```text
draft
-> spec
-> plan
-> tasks
-> dispatch
-> implement
-> test
-> review
-> fix
-> archive
-> done
```

重要区别：

- `archive` 表示 feature bundle 本身已经完整
- `done` 表示项目级 summary records 也已经完整

阶段检查当前编码在 `bin/agentflow` 中：

| 阶段 | Runtime 检查 |
| --- | --- |
| `spec` | `spec.md` 存在、无占位符、包含 goal/scope/acceptance criteria，且要求时 `spec-review.md` 通过 |
| `plan` | `spec` 通过，`plan.md` 有 implementation approach、changed files、risk analysis，且要求时 `plan-review.md` 通过 |
| `tasks` | `plan` 通过，`tasks.md` 包含带 owner/role 信号的可执行任务，且要求时 `task-review.md` 通过 |
| `dispatch` | `tasks` 通过，且 `dispatch.md` 有角色分配行 |
| `implement` | `dispatch` 通过，且配置要求的 implementation result records 完成 |
| `test` | `implement` 通过，且要求时 `implementation/test.md` 为 passed/complete |
| `review` | `test` 通过，且要求时 `implementation/review.md` 有最终非阻塞决策 |
| `fix` | `review` 通过，且 `results/fix.md` 完成 |
| `archive` | `fix` 通过，dispatch record policy 通过，且 `archive.md` 的 summary/change/test/risk sections 完成 |
| `done` | `archive` 通过，且要求时 review/test/done summary records 完成 |

`agentflow check FEATURE` 验证 bundle 结构和占位符。它不判断阶段是否可以推进。`agentflow gate STAGE FEATURE` 是 canonical 的无状态变更 gate 决策命令，会输出稳定的 `Gate Decision` 和 `Blockers`。兼容形式如 `agentflow feature gate FEATURE --to STAGE` 仍然可用。

对 agents 和脚本来说，CLI 输出是当前 feature 状态的事实来源。不要只从任务板推断阶段状态。

## 输出示例

阻塞状态示例：

```text
Feature: FEATURE-001-demo
Current Stage: draft
Next Gate: plan
Progress: 0%
Gate Status: blocked before plan
Top Blockers:
  - spec.md still contains placeholders
  - spec-review.md status is still pending
```

gate 通过示例：

```text
Gate Decision: pass
Feature: FEATURE-001-demo
Stage: spec
```

生成 context 示例：

```json
{
  "feature": "FEATURE-001-demo",
  "current_stage": "spec",
  "next_gate": "tasks",
  "open_tasks": [],
  "key_files": []
}
```

## Records 策略

推荐默认值：

- durable and versioned：feature specs、plans、tasks、test summaries、review summaries、fix summaries、archives、done records 和 `.agentflow/state/features.yml`
- generated and ignored：除 `features.yml` 外的 `.agentflow/state/*`
- transient by default：`project-docs/records/dispatch/`

需要完整审计轨迹的项目可以从 `.gitignore` 中移除 `project-docs/records/dispatch/`，并将 dispatch records 视为 durable history。

## Board State

`project-docs/03_TASK_BOARD.md` 是渲染输出。源数据是：

```text
.agentflow/state/features.yml
```

用以下命令渲染 Markdown board：

```sh
agentflow board render
```

`feature create` 和 `feature archive` 会更新 `features.yml` 并渲染 board。人工修正 board 时，应修改 `features.yml`，再渲染回 Markdown。

## 模板任务同步模型

`agentflow feature sync` 只更新标准生成任务：

- `T001` API/contracts
- `T002-T004` implementation
- `T005` test
- `T006` review
- `T007` fix
- `T008-T009` completion/archive

自定义任务行不会被修改。

## Parser 约束

当前配置读取器有意保持轻量。

安全模式：

- 简单顶层 scalar
- 两层嵌套字段，例如 `project.feature_dir`
- `hooks.before_<stage>` 和 `hooks.after_<stage>` 下的 hook list

暂时避免：

- 深层自定义结构
- anchors 或高级 YAML 特性
- 需要精确解析的多行值

## 推荐默认值

对大多数长期项目：

- `profile: standard`
- `complexity_profile: standard`
- 所有 review/test/done gates 启用
- runtime state 被 Git ignore
- dispatch records 被 Git ignore，除非项目明确需要

## 迁移说明

对于已有 Markdown-only 项目：

1. 添加或更新 `agentflow.config.yml`。
2. 将 `project.feature_dir` 和 `project.docs_dir` 指向现有布局。
3. 确保 active feature 具备标准 bundle 文件。
4. 运行 `agentflow feature status FEATURE-XXX-*`。
5. 修复 runtime 报告的最早 blocker。
6. 重复运行 `agentflow feature next FEATURE-XXX-*`，直到 feature 到达 `archive` 或 `done`。

迁移是增量的。先从 active feature 开始，不需要重写全部历史工作。

## 相关文档

- [README.md](../README.md)
- [runtime-guardrails-todo.md](./runtime-guardrails-todo.md)
