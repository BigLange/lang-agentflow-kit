# AgentFlow 配置参考

本文是 `agentflow.config.yml` 的字段参考。想看“配置什么时候触发、实际怎么生效”的例子，请先读 [config-guide.md](./config-guide.md)。

`agentflow.config.yml` 决定：

- feature（功能工作包）文件放在哪里
- 默认创建哪种 feature 类型
- 当前项目需要后端、前端、移动端哪些实现结果
- 哪些阶段需要审查
- 是否启用第三方模块复用检查
- 是否在特定阶段自动运行命令

当前 CLI 解析器比较轻量，请尽量使用简单、清晰的 YAML。

## 最常改的配置

| 配置 | 作用 | 常见改法 |
| --- | --- | --- |
| `workflow.default_type` | 不写 `--type` 时默认创建哪种功能类型 | `standard`、`major`、`sensitive` |
| `implementation.target_sides` | 当前项目要检查哪些端的实现结果 | 只保留 `backend`，或保留 `backend/frontend/mobile` |
| `gates.require_*` | 是否要求 spec/plan/tasks/review/test 等检查 | 小项目可关闭部分 review |
| `review.<stage>.mode` | 审查由谁完成 | `self` 自审、`separate-session` 独立会话、`human` 人工批准 |
| `external_module_policy` | 外部模块能否复制、纳入项目或只参考 | 高风险模块建议 `reference-only` 只参考 |

## 带注释的完整示例

```yaml
# 配置文件版本。当前固定写 1。
version: 1

# 初始化 profile：lite / standard / full。
profile: standard

# 复杂度标签：light / standard / strict。
complexity_profile: standard

project:
  # feature bundle（功能工作包）存放目录。
  feature_dir: features

  # 项目文档目录。
  docs_dir: project-docs

runtime:
  # 运行时状态文件目录。
  state_dir: .agentflow/state

  # agentflow feature context 生成的 JSON 文件名。
  active_context_file: active_context.json

  # agentflow feature context 生成的 Markdown 文件名。
  active_context_markdown_file: active_context.md

  # 是否在 dispatch（任务分派）前强制检查 gate（阶段门禁）。
  enforce_dispatch_gate: true

  # 是否在 archive（归档）前强制检查 gate（阶段门禁）。
  enforce_archive_gate: true

  # sensitive feature 是否必须先通过外部模块复用风险检查。
  require_reuse_gate_for_sensitive: true

  # hook 命令失败时怎么办：stop = 立即失败，warn = 只警告。
  hook_failure_policy: stop

workflow:
  # 创建功能时如果不写 --type，就使用这个类型。
  default_type: standard

implementation:
  # 当前项目需要哪些端的实现结果。
  target_sides:
    - backend
    - frontend
    - mobile

gates:
  # spec 阶段是否要求 spec-review.md 通过。
  require_spec_review: true

  # plan 阶段是否要求 plan-review.md 通过。
  require_plan_review: true

  # tasks 阶段是否要求 task-review.md 通过。
  require_task_review: true

  # archive 前是否要求 dispatch record。
  require_dispatch_record_for_archive: true

  # done 前是否要求 review/test/done summary records。
  require_summary_records_for_done: true

  # done 前是否要求测试记录通过。
  require_tests_before_done: true

  # 提交或收尾前是否要求 review 记录通过。
  require_review_before_commit: true

review:
  # self = 当前 AI/session 可以自审
  # separate-session = 要求另一个独立会话审查
  # human = 要求人用 agentflow approve 写入批准
  spec:
    mode: self
  plan:
    mode: self
  tasks:
    mode: self
  implementation:
    mode: self

hooks:
  # 可选：进入某阶段前后自动运行命令。
  # {{FEATURE}} 会替换成当前 feature ID。
  after_plan:
    - bin/agentflow feature context {{FEATURE}}
  after_implement:
    - bin/agentflow feature verify {{FEATURE}} --stage implement

external_module_policy:
  # 公共第三方模块默认只允许参考，不直接复制。
  public_default_mode: reference-only

  # 是否允许公共模块以 vendor 方式纳入项目。
  public_vendor_allowed: false

  # 敏感领域。命中这些领域时，应更严格检查。
  sensitive_domains:
    critical:
      - auth
      - user
      - permission
      - payment
      - crypto
      - file-upload
      - admin-account
```

## 字段说明

### 顶层字段

| 字段 | 说明 |
| --- | --- |
| `version` | 配置文件版本。当前模板固定为 `1`。 |
| `profile` | 初始化模式：`lite`、`standard`、`full`。 |
| `complexity_profile` | 面向人和 AI 的复杂度标签：`light`、`standard`、`strict`。 |

### `project`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `project.feature_dir` | `features` | feature bundle 存放目录。 |
| `project.docs_dir` | `project-docs` | 项目文档、任务板和 records 目录。 |

### `runtime`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `runtime.state_dir` | `.agentflow/state` | 生成运行时状态文件的目录。 |
| `runtime.active_context_file` | `active_context.json` | JSON 上下文文件名。 |
| `runtime.active_context_markdown_file` | `active_context.md` | Markdown 上下文文件名，推荐 AI 接手时先读。 |
| `runtime.enforce_dispatch_gate` | `true` | 进入 dispatch 前是否强制检查 gate。 |
| `runtime.enforce_archive_gate` | `true` | archive 前是否强制检查 gate。 |
| `runtime.require_reuse_gate_for_sensitive` | `true` | sensitive feature 是否需要外部模块复用检查。 |
| `runtime.hook_failure_policy` | `stop` | hook 失败时 `stop` 停止，或 `warn` 只警告。 |

### `workflow`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `workflow.default_type` | `standard` | 创建 feature 时不写 `--type` 使用的默认类型。 |

### `implementation`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `implementation.target_sides` | `backend`, `frontend`, `mobile` | 当前项目要求哪些端的实现结果。 |

支持值：

```text
backend
frontend
mobile
```

### `gates`

| 字段 | 说明 |
| --- | --- |
| `gates.require_spec_review` | spec 阶段是否要求 `spec-review.md` 通过。 |
| `gates.require_plan_review` | plan 阶段是否要求 `plan-review.md` 通过。 |
| `gates.require_task_review` | tasks 阶段是否要求 `task-review.md` 通过。 |
| `gates.require_dispatch_record_for_archive` | archive 前是否要求 dispatch record。 |
| `gates.require_summary_records_for_done` | done 前是否要求 review/test/done summary records。 |
| `gates.require_tests_before_done` | done 前是否要求测试记录通过。 |
| `gates.require_review_before_commit` | 提交或收尾前是否要求 review 记录通过。 |

### `review`

支持模式：

| 值 | 含义 |
| --- | --- |
| `self` | 当前 AI/session 可以自审，成本最低。 |
| `separate-session` | 要求另一个独立 AI 会话审查。 |
| `human` | 要求人使用 `agentflow approve` 写入批准。 |

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

### `hooks`

Hook 是在某个阶段前后自动运行的命令。支持名称：

```text
before_plan
before_tasks
before_dispatch
before_implement
before_test
before_review
before_fix
before_archive
after_spec
after_plan
after_tasks
after_dispatch
after_implement
after_test
after_review
after_fix
```

支持占位符：

| 占位符 | 会替换成 |
| --- | --- |
| `{{FEATURE}}` | 当前 feature ID |
| `{{FEATURE_DIR}}` | 当前 feature 目录 |
| `{{PROJECT_ROOT}}` | 项目根目录 |
| `{{STAGE}}` | 当前阶段 |

### `external_module_policy`

| 字段 | 说明 |
| --- | --- |
| `public_default_mode` | 公共第三方模块默认复用方式，建议 `reference-only`。 |
| `public_vendor_allowed` | 是否允许公共模块以 vendor 方式纳入项目，建议 `false`。 |
| `sensitive_domains.critical` | 高风险领域列表，例如 auth、user、payment。 |

复用模式：

| 值 | 含义 |
| --- | --- |
| `reference-only` | 只参考设计、接口或交互，不复制代码。 |
| `vendor` | 把外部模块作为供应商代码纳入项目。 |
| `direct-copy` | 直接复制公共代码。 |

## Feature 类型和阶段

| 类型 | 中文说明 | 适合场景 |
| --- | --- | --- |
| `trivial` | 极小改动 | 文案、样式、配置、小范围调整 |
| `bug` | 缺陷修复 | 已知问题修复 |
| `standard` | 标准功能 | 普通业务功能 |
| `major` | 复杂功能 | 多端、多模块、影响范围大 |
| `sensitive` | 高风险功能 | 用户、权限、支付、上传、加密、租户隔离、外部模块复用 |

每种类型对应的阶段：

| 类型 | 阶段 |
| --- | --- |
| `trivial` | `implement` -> `archive` |
| `bug` | `implement` -> `test` -> `archive` |
| `standard` | `spec` -> `plan` -> `tasks` -> `implement` -> `test` -> `archive` |
| `major` | `spec` -> `plan` -> `tasks` -> `dispatch` -> `implement` -> `test` -> `review` -> `fix` -> `archive` |
| `sensitive` | `spec` -> `reuse-risk` -> `plan` -> `tasks` -> `dispatch` -> `implement` -> `security-review` -> `test` -> `review` -> `fix` -> `archive` |

阶段含义：

| 阶段 | 含义 |
| --- | --- |
| `spec` | 写清需求、范围、验收标准和非目标 |
| `reuse-risk` | 分析外部模块复用风险 |
| `plan` | 写技术方案、影响范围和测试策略 |
| `tasks` | 拆成可执行任务 |
| `dispatch` | 分派任务给角色或 agent |
| `implement` | 编码实现 |
| `security-review` | 安全、权限、数据隔离专项检查 |
| `test` | 测试和验证 |
| `review` | 代码或实现审查 |
| `fix` | 修复测试或审查发现的问题 |
| `archive` | 归档结果、变更、测试和风险 |

## 只作说明的字段

配置中有些字段主要给人、AI 或未来 adapter 看，当前 CLI 不强依赖：

- `spec.provider`
- `spec.source_dir`
- `spec.required_outputs`
- `orchestrator.provider`
- `orchestrator.default_mode`
- `skills.provider`
- `skills.role_method_map`
- `integrations.*`
- `archive.provider`

这些字段可以帮助表达项目意图，但不要指望当前 Bash runtime 完整执行它们。

## 配置写法限制

推荐使用：

- 简单字段，例如 `profile: standard`
- 两层配置，例如 `project.feature_dir`
- 简单列表，例如 `target_sides`
- 简单 hook 命令列表

暂时避免：

- 很深的嵌套结构
- YAML anchors
- 复杂多行字符串
- 依赖 shell 特性的复杂命令

## 推荐默认配置

大多数长期项目建议：

- `profile: standard`
- `complexity_profile: standard`
- `workflow.default_type: standard`
- `implementation.target_sides` 按真实项目端来配置
- 用户、权限、支付、安全相关 feature 使用 `sensitive`
- 公共第三方模块默认 `reference-only`
- 不直接编辑任务板，使用 `agentflow board render`

## 相关文档

- [README.md](../README.md)
- [使用说明手册](./user-manual.md)
- [配置快速指南](./config-guide.md)
- [Runtime Guardrails TODO](./runtime-guardrails-todo.md)
