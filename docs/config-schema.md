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
| `manager.resume_prompt` | 日常启动短语 | 默认 `你是 Manager，请继续开发。` |
| `manager.heartbeat_phrase` | Manager 每轮结束必须输出的心跳口令 | 默认 `AI为你保驾护航` |
| `manager.heartbeat_mode` | 心跳输出模式 | `compact`、`full`、`off` |
| `external_module_policy` | 外部模块能否复制、纳入项目或只参考 | 高风险模块建议 `reference-only` 只参考 |

## 带注释的完整示例

```yaml
# AgentFlow 项目配置。
#
# 给 AI Manager 的说明：
# - 创建 feature 或继续开发前，先读取本文件。
# - 通过 project.docs_dir 找到 project-docs/ACTIVE_WORK.md。
# - 用户没有指定 --type 时，使用 workflow.default_type。
# - 根据 implementation.target_sides 判断需要 backend/frontend/mobile 哪些结果文件。
# - 根据 gates 和 review 判断哪些检查必须通过。
# - 优先把重复检查放进 hooks，不要让人每天手动跑一串命令。
# - 每轮结束必须更新 project-docs/ACTIVE_WORK.md，并按 manager.heartbeat_mode 输出心跳。
#
# 给人和 AI 的配置原则：
# - 需要调整 YAML 时，AI 必须先说明“为什么要改、改哪些字段、改完有什么影响”。
# - 用户确认前，AI 不要直接修改本文件；确认后再编辑、验证并记录到 ACTIVE_WORK.md。
# - AI 修改后必须检查 YAML 语法，并运行必要的 agentflow status/gate/check。
# - 如果项目没有移动端，删除 implementation.target_sides 里的 mobile。
# - auth/user/permission/payment/upload/crypto 等高风险功能应使用 sensitive。
# - 公共第三方模块默认 reference-only，不要直接复制安全关键代码。

# 配置文件版本。当前固定写 1。
version: 1

# 初始化 profile：lite / standard / full。
profile: standard

# 复杂度标签：light / standard / strict。
complexity_profile: standard

manager:
  # 日常启动短语。用户可以只说这句话，AI 应读取 AGENTS.md、
  # agentflow.config.yml 和 project-docs/ACTIVE_WORK.md 后继续。
  resume_prompt: "你是 Manager，请继续开发。"

  # Manager 每轮结束必须输出的心跳口令。
  # 人可以改成任何容易识别的短句，用来发现 AI 是否开始忘记规则。
  heartbeat_phrase: "AI为你保驾护航"

  # 心跳输出模式：
  # compact = 默认，只输出一行短心跳，适合日常使用。
  # full = 输出完整 anchor_pulse YAML，适合调试或严格审计。
  # off = 关闭心跳，不推荐。
  heartbeat_mode: compact

project:
  # 项目目录约定。AI 只有在项目确实使用了不同目录名时才建议修改。
  # docs_dir 会决定 ACTIVE_WORK.md、任务板、records 等文件的位置。

  # feature bundle（功能工作包）存放目录。
  feature_dir: features

  # 项目文档目录。
  docs_dir: project-docs

runtime:
  # runtime 是 CLI 的工作状态和自动检查配置。
  # AI 修改规则：正式项目保持 gate 强制开启；只有临时实验才考虑关闭。

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
  # 默认 feature 类型。
  # AI 修改规则：普通业务用 standard；跨多端/多模块用 major；
  # 涉及用户、权限、支付、上传、加密、租户隔离或外部模块复用时用 sensitive。
  default_type: standard

implementation:
  # 当前项目包含哪些实现端。
  # AI 修改规则：没有移动端就删除 mobile；纯后端只保留 backend；
  # 这会影响 results/<side>.md 的生成和 gate 检查。
  target_sides:
    - backend
    - frontend
    - mobile

gates:
  # gate 是阶段门禁。true 表示进入下一阶段前必须满足对应检查。
  # AI 修改规则：为降低复杂度可以关闭部分 review gate；
  # 但涉及安全、权限、支付、用户数据、外部模块时不要随意关闭。

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
  # 审查模式。
  # self = 当前会话自审，成本低；separate-session = 独立 AI 会话审查；
  # human = 必须由人运行 agentflow approve。
  # AI 修改规则：安全、权限、支付、关键架构决策建议使用 human 或 separate-session。
  spec:
    mode: self
  plan:
    mode: self
  tasks:
    mode: self
  implementation:
    mode: self

hooks:
  # 阶段前后自动运行的命令。
  # AI 修改规则：把重复的 status/context/gate/test/board render 放进 hooks，
  # 减少用户手动输入命令；命令保持简单，不要写复杂 shell。
  after_plan:
    - bin/agentflow feature context {{FEATURE}}
  after_implement:
    - bin/agentflow feature verify {{FEATURE}} --stage implement

external_module_policy:
  # 外部模块复用策略。
  # AI 修改规则：公共模块默认只 reference-only；auth/user/permission/payment/upload/crypto
  # 等敏感模块不要 direct-copy，vendor 也需要人工确认。
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

文件顶部这段注释不会影响 CLI 解析。它是给 AI Manager 和人看的启动说明，目的是让 AI 在新会话里直接知道：

- 先读配置和 `ACTIVE_WORK.md`
- 如何选择默认 feature 类型
- 哪些端的结果必须补
- 哪些 gate/review 必须通过
- 哪些重复检查应交给 hook
- 每轮结束必须更新 `ACTIVE_WORK.md` 并按 `manager.heartbeat_mode` 输出心跳

这些中文注释也用于指导 AI 修改 YAML。推荐规则是：先提出建议，说明原因和影响，等用户确认后再改；改完必须验证 YAML，并运行必要的 `agentflow status/gate/check`。

## 字段说明

### 顶层字段

| 字段 | 说明 |
| --- | --- |
| `version` | 配置文件版本。当前模板固定为 `1`。 |
| `profile` | 初始化模式：`lite`、`standard`、`full`。 |
| `complexity_profile` | 面向人和 AI 的复杂度标签：`light`、`standard`、`strict`。 |

### `manager`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `manager.heartbeat_phrase` | `AI为你保驾护航` | Manager 每轮结束必须输出的心跳口令。缺失时说明可能需要重新读取上下文。 |

### `project`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `project.feature_dir` | `features` | feature bundle 存放目录。 |
| `project.docs_dir` | `project-docs` | 项目文档、`ACTIVE_WORK.md`、任务板和 records 目录。 |

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

### `subagents`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `subagents.default_model_profile` | `medium` | Manager 无法判断时使用的默认模型档位。 |
| `subagents.model_profiles` | `low`, `medium`, `high`, `extra-high` | 中性 reasoning 档位到具体 provider/model 参数的项目级映射。 |
| `subagents.routing_rules` | 按 feature type 映射 | 创建 feature 时生成 `model-routing.md` 的默认依据。 |

当前 CLI 只生成和检查路由建议，不直接调用外部模型。Manager 或外部 adapter
应读取 `model-routing.md`、`dispatch.md` 和 task metadata，再把 `low`、
`medium`、`high`、`extra-high` 映射到实际可用 provider 的参数。Codex 可以映射
reasoning effort；Claude Code 或其他工具可以映射到它们自己的模型名、计划模式
或子代理配置。

内置 Codex adapter 支持：

```sh
agentflow stage plan FEATURE-XXX --stage spec --adapter codex
agentflow stage run FEATURE-XXX --stage spec --adapter codex
agentflow stage run FEATURE-XXX --stage spec --adapter codex --execute
agentflow dispatch plan FEATURE-XXX --adapter codex
agentflow dispatch run FEATURE-XXX --adapter codex
agentflow dispatch run FEATURE-XXX --adapter codex --execute
```

`stage` 用于 spec/plan/tasks/review 等前置阶段，`dispatch` 用于实现、测试、
审查、修复、归档这些分派任务。`run` 默认只提示脚本路径，只有加 `--execute`
才实际调用 `codex exec`。

### `testing`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `testing.ai_required` | `true` | AI/自动化测试是否作为 feature 级强制闭环。 |
| `testing.require_test_cases` | `true` | test 阶段是否要求独立 `test-cases.md`。 |
| `testing.require_test_results` | `true` | test 阶段是否要求独立 `test-results.md`。 |
| `testing.manual_acceptance.enabled` | `true` | 是否生成并维护项目级人工验收清单。 |
| `testing.manual_acceptance.blocking_level` | `release` | 人工验收通常在 feature 之后集中处理，可按 milestone/release 卡口使用。 |
| `testing.manual_acceptance.allow_pending_before_archive` | `true` | 允许 feature 归档时人工验收仍为 pending。 |

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

test 阶段会检查 `test-cases.md`、`test-results.md` 和
`implementation/test.md` 的 AI/自动化测试记录。人工 QA、网页/App 体验和
最终验收项统一汇总在 `project-docs/04_MANUAL_ACCEPTANCE.md`，feature 内的
`manual-acceptance.md` 只保留本地摘要，允许保持 `Status: pending`，用于后续
人工 QA 或产品验收集中更新。

dispatch 阶段会检查 `model-routing.md`。Manager 应在分派前确认每个任务的
`complexity`、`risk` 和 `model_profile`，高风险或敏感任务应提升到 `high` 或
`extra-high`。

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
