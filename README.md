# Lang AgentFlow Kit

Current version: `0.5.0`

Lang AgentFlow Kit 是一个本地项目初始化工具，用来给项目生成一套
**subagent-first** 的 AI 开发协作架构。

它的目标不是适配所有开发场景。

它主要面向：

- 个人开发者或小团队
- 长时间 AI 协作开发
- 多阶段、多交接、上下文很长的复杂项目

它不主要为这些场景设计：

- 几行代码修改
- 一次性脚本
- 临时实验
- 快速 vibe coding

它吸收了几类体系的优点：

- spec-kit 的阶段化产物：`spec.md`、`plan.md`、`tasks.md`
- Superpowers 的工作方法：需求澄清、写计划、TDD、代码审查、系统化修复
- Oh My Codex 的团队编排思路：作为可替换的 orchestrator adapter
- 你自己的留档体系：任务板、dispatch、done、review、test、archive records

核心目标是：为复杂 AI-native 软件项目建立长期稳定的工程秩序，减少上下文漂移、流程遗忘、Agent 交接混乱和长链路任务失控。

当前稳定核心有两层：

- Markdown 协议层：`AGENTS.md`、`project-docs/`、Feature Bundle、records
- 轻量 runtime 守卫层：`check`、`verify`、`gate`、`context`、`status`、`board render`

也就是说，Lang AgentFlow Kit 不只是“生成模板”，还开始提供可执行的流程约束。

## What's New In 0.5.0

`0.5.0` 是 next-stage hardening 版本。相比 `0.2.0` 只提供第一版
runtime guardrails，这一版把 AgentFlow 继续推进到“配置掌权 + gate 语义清晰 +
active context 可交接 + task board state 化 + review isolation”的状态。

### Why This Release Exists

`0.2.0` 已经能检查阶段产物、阻断不合格 gate、生成 active context 和输出 status，
但长任务继续跑久以后，新的问题会暴露出来：

- `agentflow.config.yml` 写着关闭某个流程，但 CLI 仍然生成或检查对应文件。
- `check` 和 `gate` 混在一起，用户只是想看 gate，却可能触发推进副作用。
- active context 只有 JSON，对 Agent 来说还不是足够明确的开工入口。
- `project-docs/03_TASK_BOARD.md` 作为 Markdown 表格容易被手改坏，也不适合作为机器状态源。
- review 文件存在并不代表真的隔离审查，高风险阶段可能被自审悄悄放过。

`0.5.0` 解决的是这个问题：**让已有 Markdown 合同更难被绕过，同时让后续日常操作更确定、更少人工翻文档、更容易交接。**

### What Gets Better

这次优化带来的直接收益：

- **YAML 真正掌权**：关闭 spec/plan/task review 或只启用 backend 实现端后，CLI 不再生成、不再检查、不再因此阻塞。
- **减少误操作**：`check` 只检查结构和占位符，`gate` 只输出 pass/block，只有 `next/advance/archive` 才推进状态。
- **降低交接成本**：`active_context.md` 成为 Agent 开工前的短工作合同，明确当前 gate、必读文件、禁止动作和下一步。
- **任务板更稳定**：`.agentflow/state/features.yml` 成为 canonical state，Markdown task board 可以随时 render 重建。
- **审查更可信**：`review.mode` 可以要求 self warning、separate-session metadata 或 CLI human approval。
- **后续操作更少猜测**：Manager 和 subagent 可以依赖 `status`、`gate`、`context`、`board render` 的输出，而不是凭对话记忆判断状态。

主要变化：

- `agentflow.config.yml` 的 `gates.*` 和 `implementation.target_sides` 已参与生成和检查。
- 新增 canonical gate 命令：`agentflow gate STAGE FEATURE`。
- `feature context` 同时生成 `.agentflow/state/active_context.md` 和 `.agentflow/state/active_context.json`。
- 新增 `.agentflow/state/features.yml` 和 `agentflow board render`。
- 新增 `review.<stage>.mode` 和 `agentflow approve FEATURE --stage <stage>`。
- `full` profile 默认启用更强 review isolation。
- README、config schema、介绍文档、roadmap 和 changelog 已同步到当前行为。

推荐的日常命令面已经收敛为：

```sh
agentflow feature create "user auth"
agentflow feature next FEATURE-001-user-auth
agentflow feature status FEATURE-001-user-auth
```

这三个命令覆盖大多数 feature 的创建、推进和状态同步。

需要调试或人工确认时，再使用：

```sh
agentflow check FEATURE-001-user-auth
agentflow gate spec FEATURE-001-user-auth
agentflow feature context FEATURE-001-user-auth
agentflow board render
```

## Installation

从 GitHub 安装：

```sh
npm install -g github:BigLange/lang-agentflow-kit
```

进入任意项目后初始化：

```sh
agentflow init --profile standard
```

从源码目录直接运行：

```sh
/path/to/lang-agentflow-kit/bin/agentflow init --profile standard
```

本地开发调试：

```sh
npm link
cd /path/to/project
agentflow init --profile standard
```

## Init Profiles

| Profile | Includes | Best For | Pros | Cons |
| --- | --- | --- | --- | --- |
| `lite` | AgentFlow 核心文件、`AGENTS.md`、项目文档、feature 模板、records、较轻 runtime | 想低成本引入协议和基础卡口的复杂项目 | 初始化轻、规则少一点 | 不适合强治理阶段 |
| `standard` | `lite` 全部内容 + 本地 vendored Superpowers-style skills | 默认推荐，适合大多数长期复杂项目 | 方法论完整，适合 Codex subagents | 比 `lite` 更严格 |
| `full` | `standard` 全部内容 + `.agentflow/integrations/oh-my-codex.yml` | 需要外部 orchestrator 接入位的项目 | 最完整；具备 adapter 位置 | 最重；Oh My Codex 只是配置好 adapter，不代表已真正运行 |

推荐默认使用：

```sh
agentflow init --profile standard
```

什么时候选：

- 想先上协议和基础卡口：`lite`
- 想认真做长期项目：`standard`
- 想接 Oh My Codex / 多 Agent 团队编排：`full`

## Generated Files

```text
AGENTS.md
agentflow.config.yml
.agentflow/
  agents/
  templates/
  skills/                 # standard/full 才有
  integrations/           # full 会包含 oh-my-codex.yml
  state/
    features.yml          # task board source state
    active_context.*      # generated runtime context
project-docs/
  00_PROJECT_CONTEXT.md
  01_ARCHITECTURE.md
  02_API_SPEC.md
  03_TASK_BOARD.md
  records/
features/
```

其中 `AGENTS.md` 是 AI 入口文件。初始化后，如果是新项目，应该先和 AI 讨论项目目标、用户、技术栈、边界和架构，而不是马上执行 `agentflow feature create`。

## New Project Flow

从零开始做一个项目时，推荐流程是：

```text
1. agentflow init --profile standard
2. 直接和 AI 对话：我要做一个什么项目，用户是谁，核心功能是什么
3. Manager 补齐 project-docs/00_PROJECT_CONTEXT.md
4. Manager 补齐 project-docs/01_ARCHITECTURE.md
5. Manager 更新 project-docs/02_API_SPEC.md 和 03_TASK_BOARD.md
6. 项目级方向明确后，再拆分 features/FEATURE-XXX-*
7. 每个 feature 进入 spec -> plan -> tasks -> dispatch -> implement -> test -> review -> fix -> archive
```

也就是说：

```sh
agentflow init --profile standard
```

之后你可以直接对 AI 说：

```text
我要做一个 AI CRM 系统，面向小团队销售，核心功能包括客户管理、跟进记录、AI 总结和权限管理。
```

AI 应先根据 `AGENTS.md` 和 `project-docs/` 进入项目澄清与架构阶段，而不是立刻写代码。

## Feature Flow

`agentflow feature create "..."` 适合已有项目新增功能，或者项目级上下文已经明确之后拆出来的功能。

示例：

```sh
agentflow feature create "user auth"
agentflow feature next FEATURE-001-user-auth
agentflow feature status FEATURE-001-user-auth
```

生成的 feature bundle 结构：

```text
features/FEATURE-XXX-name/
├── spec.md
├── spec-review.md
├── plan.md
├── plan-review.md
├── tasks.md
├── task-review.md
├── dispatch.md
├── implementation/
│   ├── api.md
│   ├── test.md
│   └── review.md
├── results/
│   ├── backend.md
│   ├── fix.md
│   ├── frontend.md
│   └── mobile.md
└── archive.md
```

实际生成内容由项目根目录的 `agentflow.config.yml` 控制。如果配置不存在，
CLI 使用内置默认配置。当前已 runtime-enforced 的开关包括：

- `gates.require_spec_review: false`：不生成、不检查 `spec-review.md`，也不因
  spec review 缺失阻塞 gate。
- `gates.require_plan_review: false`：不生成、不检查 `plan-review.md`。
- `gates.require_task_review: false`：不生成、不检查 `task-review.md`。
- `implementation.target_sides`：只生成和检查列出的实现结果文件。例如只配置
  `backend` 时，不生成、不检查 `results/frontend.md` 和 `results/mobile.md`。

## Workflow Stages

完整开发链路可以理解为：

```text
项目澄清
-> 项目上下文
-> 架构/API 边界
-> Feature 拆分
-> Spec 创建/检查
-> Plan 创建/检查
-> Tasks 创建/检查
-> API / 接口设计
-> 后端 / 前端 / 移动端实现
-> 测试验证
-> 代码审查
-> 问题修复
-> 归档 / 提交说明
```

当前 CLI 已经开始把这条链路中的关键部分做成 runtime 阶段校验：

```text
spec -> plan -> tasks -> dispatch -> implement -> test -> review -> fix -> archive
```

这意味着后续不再只是“提醒 AI 应该做什么”，而是逐步变成“前一阶段没过，下一阶段就过不去”。

## Runtime Guardrails

当前内置的轻量 runtime 命令有：

```sh
agentflow feature create "user auth"
agentflow feature next FEATURE-001-demo
agentflow feature status FEATURE-001-demo
```

它们分别负责：

- `create`: 创建一个新的 feature bundle
- `next`: 自动判断下一步，并串行执行 gate、任务同步、context 刷新和状态输出
- `status`: 输出当前阶段、下一道 gate、推断进度、task checklist 状态、records 状态和主要阻塞项
- `archive`: 保留为高级命令；大多数情况下 `next` 会替你推进到 archive/done

这里的 `archive` 和 `done` 不是一回事：

- `archive`: feature bundle 本身已经完整
- `done`: project-level summary records 也已经完整

底层高级命令仍然存在：

- `verify`: 校验某阶段产物是否完整，是否仍有占位符、pending verdict、未完成 checklist
- `gate`: 在阶段切换前执行硬性卡口
- `advance`: 显式推进到某个目标阶段
- `context`: 生成 `.agentflow/state/active_context.json`，给 AI 一个压缩后的当前工作视图
- `sync`: 根据当前 runtime 阶段同步标准 `T001-T009` 任务清单，不改自定义任务

设计原则是：

- 保留 Markdown 合同
- 增加轻量 runtime 约束
- 不引入笨重平台或后台服务

推荐把日常命令面压缩成这一组：

- `agentflow feature create`
- `agentflow feature next`
- `agentflow feature status`

如果用户只记 3 个命令，优先记这 3 个。大多数日常推进都可以靠反复执行 `feature next` 完成。

其它子命令保留给调试、精细控制和高级用法。`feature archive` 也保留，但不再是默认学习路径。旧的顶层命令目前仍然保留兼容，但不再是推荐主路径。

完整配置字段说明见：

- [docs/config-schema.md](./docs/config-schema.md)

## YAML Configuration Controls Runtime Behavior

`agentflow.config.yml` 是当前项目的 runtime 控制面。CLI 会把内置默认值和项目里的
YAML 合并成 effective config，然后用这份配置决定：

- `feature create` 生成哪些文件
- `check` 检查哪些文件和占位符
- `gate` 哪些缺口会阻塞阶段通过
- `context` 输出哪些 required/must-read 文件
- `board render` 从哪里读取 feature state
- review gate 是否接受自审，还是要求独立 session 或人工批准

也就是说，YAML 不是注释或说明文档。配置关掉的流程，CLI 不应该继续生成、检查或阻塞。

### Common Config Effects

| Config | Runtime Effect | Typical Use |
| --- | --- | --- |
| `project.feature_dir` | 改变 feature bundle 查找和生成目录 | 非默认 `features/` 布局 |
| `project.docs_dir` | 改变 project docs、records、task board 路径 | 项目文档目录有自定义命名 |
| `runtime.state_dir` | 改变 active context 和 board state 输出目录 | 想把 runtime state 放到自定义位置 |
| `runtime.active_context_file` | 改变 JSON active context 文件名 | 工具侧依赖固定文件名 |
| `runtime.active_context_markdown_file` | 改变 Markdown active context 文件名 | Agent 开工入口需要自定义 |
| `runtime.enforce_dispatch_gate` | 控制 `feature dispatch` 是否先执行 dispatch gate | 想把 dispatch 从硬卡口改为人工控制 |
| `runtime.enforce_archive_gate` | 控制 `feature archive` 是否先执行 archive gate | 想手动归档历史 feature |
| `gates.require_spec_review` | `false` 时不生成、不检查、不阻塞 `spec-review.md` | 低治理项目或快速 spec |
| `gates.require_plan_review` | `false` 时不生成、不检查、不阻塞 `plan-review.md` | plan review 由团队外部流程完成 |
| `gates.require_task_review` | `false` 时不生成、不检查、不阻塞 `task-review.md` | 任务拆分较轻量 |
| `gates.require_tests_before_done` | `false` 时后续阶段不要求 `implementation/test.md` 通过 | 只做文档或非代码 feature |
| `gates.require_review_before_commit` | `false` 时后续阶段不要求 `implementation/review.md` 通过 | 外部代码审查系统接管 |
| `implementation.target_sides` | 只生成和检查列出的 result 文件 | backend-only、web-only、mobile-only 项目 |
| `review.<stage>.mode` | 控制 review gate 的隔离强度 | 高风险阶段要求独立审查或人工批准 |
| `hooks.before_<stage>` / `hooks.after_<stage>` | 在显式推进命令中运行测试、lint 或状态刷新 | 把本地验证接到 AgentFlow 流程 |

### Backend-only Example

只做后端服务时：

```yaml
implementation:
  target_sides:
    - backend
```

效果：

- `feature create` 只生成 `results/backend.md` 和通用 `results/fix.md`
- 不生成 `results/frontend.md`
- 不生成 `results/mobile.md`
- `check` 不会报 frontend/mobile result 缺失
- `gate implement` 不会因为 frontend/mobile result 缺失而阻塞
- `active_context.md` 不会把 frontend/mobile result 当作 required file

### Lighter Review Example

如果项目不需要 spec/plan/tasks 三个阶段都单独 review：

```yaml
gates:
  require_spec_review: false
  require_plan_review: false
  require_task_review: false
```

效果：

- 不生成 `spec-review.md`、`plan-review.md`、`task-review.md`
- `check` 不检查这些文件
- `gate spec/plan/tasks` 不因为这些 review 文件缺失而失败
- feature bundle 更轻，但也意味着阶段审查约束更弱

### Strong Review Example

如果 implementation review 必须由人工确认：

```yaml
review:
  implementation:
    mode: human
```

效果：

- `gate review FEATURE` 会要求 `implementation/review.md` 存在并完成
- 还必须有 CLI 写入的 human approval metadata
- 直接手写 `approved_by` 不应作为推荐路径
- 正确操作是：

```sh
agentflow approve FEATURE-001-user-auth --stage implementation
```

如果 spec review 要求另一个 AI session 审查：

```yaml
review:
  spec:
    mode: separate-session
```

对应的 `spec-review.md` 需要包含：

```yaml
review_mode: separate-session
reviewer: external
decision: approved
blocking_issues: 0
reviewed_at: 2026-05-27
```

否则 `gate spec FEATURE` 会明确阻塞。

### Hook Example

把测试接到实现后检查：

```yaml
hooks:
  after_implement:
    - npm test
```

效果：

- 纯 `agentflow gate implement FEATURE` 不运行 hook，只做判断
- `agentflow feature advance FEATURE --to test` 或 `feature next` 推进成功后会运行 hook
- 如果 `runtime.hook_failure_policy: stop`，hook 失败会中断推进
- 如果 `runtime.hook_failure_policy: warn`，hook 失败只输出警告

### Board State Example

Task board 的源数据是：

```text
.agentflow/state/features.yml
```

手动修正 feature 状态时，改这里：

```yaml
features:
  - id: "FEATURE-001-user-auth"
    title: "User Auth"
    stage: "plan"
    status: "pending"
    mode: "subagent"
    owner: "Manager"
    verified: "no"
    notes: "Waiting for plan review"
    updated_at: "2026-05-27"
```

然后运行：

```sh
agentflow board render
```

效果是重新生成 `project-docs/03_TASK_BOARD.md`。不要把 Markdown board 当作源数据长期手改。

## State-Backed Task Board

`project-docs/03_TASK_BOARD.md` 是渲染结果，不再是 feature 状态的源数据。
当前 canonical state 在：

```text
.agentflow/state/features.yml
```

重新渲染 task board：

```sh
agentflow board render
```

`feature create` 和 `feature archive` 会更新 `features.yml` 并重新渲染 board。
如果需要人工修正 feature 的 board 状态，应编辑 `features.yml`，然后运行
`agentflow board render`。

## Review Isolation

`agentflow.config.yml` 可以为 review gate 指定隔离模式：

```yaml
review:
  spec:
    mode: self
  plan:
    mode: separate-session
  tasks:
    mode: self
  implementation:
    mode: human
```

支持模式：

- `self`：兼容默认模式，gate 会提示这是弱隔离 review。
- `separate-session`：review 文件必须包含 `review_mode: separate-session`、
  `reviewer: external`、`decision`、`blocking_issues: 0` 和 `reviewed_at`。
- `human`：必须通过 CLI 写入人工批准元数据：

```sh
agentflow approve FEATURE-001-demo --stage spec
```

## Stage Model And Gates

当前 runtime 的阶段模型是：

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

每个阶段都有一个可检查的完成条件：

| Stage | Main Files | Completion Signal |
| --- | --- | --- |
| `spec` | `spec.md`, `spec-review.md` | spec 无占位符，spec review 不再 pending，gate checklist 完成 |
| `plan` | `plan.md`, `plan-review.md` | spec 已通过，plan 无占位符，plan review 完成 |
| `tasks` | `tasks.md`, `task-review.md` | plan 已通过，任务清单存在，task review 完成 |
| `dispatch` | `dispatch.md` | tasks 已通过，dispatch 表存在并分配角色 |
| `implement` | `implementation/api.md`, `results/*.md` | dispatch 已通过，API 和实现记录完成 |
| `test` | `implementation/test.md` | implement 已通过，测试记录完成 |
| `review` | `implementation/review.md` | test 已通过，审查记录完成 |
| `fix` | `results/fix.md` | review 已通过，修复记录完成 |
| `archive` | `archive.md`, dispatch record | fix 已通过，feature archive 完成 |
| `done` | review/test/done summary records | archive 已通过，项目级 summary records 完成 |

`check`、`gate` 和 `verify` 的职责分开：

- `agentflow check FEATURE`：校验 feature bundle 的结构是否完整，配置要求的文件是否存在，以及是否还有明显占位符。
- `agentflow gate STAGE FEATURE`：判断某个阶段 gate 是否通过，只输出 pass/block 和 blockers，不同步任务、不写 context、不触发 archive。
- `agentflow feature verify FEATURE --stage STAGE`：保留为兼容的阶段完成度检查入口。
- `agentflow feature advance/next`：显式推进流程，会在 gate 通过后同步任务、刷新 context 或写 records。

旧的 `agentflow feature gate FEATURE --to STAGE` 和 `agentflow gate FEATURE --to STAGE`
仍然保留兼容，但推荐新脚本使用 `agentflow gate STAGE FEATURE`。Manager 和
subagent 应把 CLI 输出当作阶段状态的 source of truth，而不是依赖对话记忆。

当前 `gates:` 使用全局 boolean 配置，例如：

```yaml
gates:
  require_spec_review: true
  require_plan_review: true
  require_task_review: true
  require_tests_before_done: true
  require_review_before_commit: true

implementation:
  target_sides:
    - backend
    - frontend
    - mobile
```

`agentflow feature create`、`agentflow check`、`agentflow feature verify` 和
`agentflow feature gate` 都按默认配置与用户配置合并后的 effective config
执行。关闭的 review/result 文件不会被生成、检查或作为 gate blocker。

这保持了 v1 runtime 的简单性。后续如果要支持更细的项目差异，可以演进成 per-stage structured rules，例如：

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

这个结构目前是未来方向，不是当前 CLI 的读取格式。

## Runtime Output Examples

一个被阻塞的 feature status 会指出当前阶段、下一道 gate 和主要缺口：

```text
Feature: FEATURE-001-user-auth
Current Stage: draft
Next Gate: plan
Progress: 0%
Open Tasks: 9
Task Checklist: 0/9 checked

Gate Status: blocked before plan
Top Blockers:
  - spec.md still contains placeholders
  - spec-review.md status is still pending
```

一个通过的 gate 会返回明确的通过信息：

```text
Gate Decision: pass
Feature: FEATURE-001-user-auth
Stage: spec
```

`feature context` 会生成小型 JSON 和 Markdown 工作合同。Markdown 版本是 Agent
开工前应先读的入口文件：

```text
.agentflow/state/active_context.md
.agentflow/state/active_context.json
```

`active_context.md` 以固定 header 开头：

```text
This is the current working contract.
Start from this file before doing any work.
Do not start coding before checking the current gate.
Only open additional docs/files when this context references them or the current task requires verification.
```

JSON 版本保留给脚本和工具读取：

```json
{
  "feature": "FEATURE-001-user-auth",
  "current_stage": "spec",
  "next_gate": "tasks",
  "goal": "User can sign in with email.",
  "next_step": "Run `agentflow gate tasks FEATURE` and resolve the first blocker before advancing.",
  "open_tasks": [],
  "required_files": [],
  "must_read": [],
  "forbidden_actions": [],
  "open_questions": [],
  "current_blockers": [],
  "key_files": []
}
```

这些输出不是为了替代 Markdown 产物，而是为了让阶段状态可执行、可检查、可交接。

## Hooks

可以在 `agentflow.config.yml` 中声明轻量 hooks。它们可以在阶段进入前或阶段完成后触发。

例如：

```yaml
hooks:
  before_dispatch:
    - bin/agentflow feature status {{FEATURE}}
  after_plan:
    - bin/agentflow feature context {{FEATURE}}
  after_implement:
    - bin/agentflow feature verify {{FEATURE}} --stage implement

runtime:
  hook_failure_policy: stop
```

当前支持的 token：

- `{{FEATURE}}`
- `{{FEATURE_DIR}}`
- `{{PROJECT_ROOT}}`
- `{{STAGE}}`

当前支持两类时机：

- `before_<stage>`: 进入目标阶段前运行
- `after_<stage>`: 前一阶段完成后运行

例如：

- `feature advance --to tasks` 会先运行 `before_tasks`，gate 成功后再运行 `after_plan`
- `feature next` 推进到 review 时，会先运行 `before_review`，gate 成功后再运行 `after_test`
- 纯 `agentflow gate STAGE FEATURE` 只做判断，不运行 hooks、不同步 tasks、不写 context

失败策略由 `runtime.hook_failure_policy` 控制：

- `stop`: hook 失败立即中断
- `warn`: 记录警告后继续

## Subagent Count

实际数量取决于任务大小。推荐的逻辑角色如下：

| Phase | Subagent Role | Expected Count |
| --- | --- | --- |
| Spec | Spec Creator、Spec Reviewer | 1-2 |
| Plan | Plan Creator、Plan Reviewer | 1-2 |
| Tasks | Task Creator、Task Reviewer | 1-2 |
| API | API Designer | 0-1 |
| 实现 | Backend、Frontend、Mobile Implementer | 1-3，取决于项目端类型 |
| 质量 | Test Agent、Code Reviewer | 1-2 |
| 修复 | Fix Agent | 每轮 0-1 |
| 收口 | Commit Agent / Manager archive | 0-1 |

经验值：

- 小功能：2-4 个 subagent
- 中等功能：4-8 个 subagent
- 长任务 / 多端任务：6-10+ 个 subagent

关键原则不是“越多越好”，而是每个 subagent 都要拿到足够窄、足够明确的上下文。

## Superpowers Integration

`standard` 和 `full` 会把轻量版 Superpowers-style skills 复制到项目内：

```text
.agentflow/skills/
```

映射关系：

| AgentFlow Role | Method |
| --- | --- |
| Spec Creator | `brainstorming` |
| Plan Creator | `writing-plans` |
| Manager / 实施编排 | `subagent-driven-development` |
| Code Reviewer | `requesting-code-review` |
| Test Agent | `test-driven-development` |
| Fix Agent | `systematic-debugging` |
| Commit Agent | `finishing-a-development-branch` |

这些 skills 是项目本地副本，可以按项目修改，不依赖用户全局安装 Superpowers。

## Oh My Codex Adapter

`full` 会生成：

```text
.agentflow/integrations/oh-my-codex.yml
```

它描述的是一个团队流水线：

```text
spec -> plan -> tasks -> api -> implement -> test -> review -> fix -> archive
```

注意：Oh My Codex 在这里是 **可替换 orchestrator adapter**，不是硬编码依赖。稳定中间层始终是：

```text
features/FEATURE-XXX-*/dispatch.md
project-docs/records/
features/FEATURE-XXX-*/results/
```

如果不想用 Oh My Codex，把 `agentflow.config.yml` 改成：

```yaml
orchestrator:
  provider: codex-subagents
  mode: subagent

integrations:
  oh_my_codex:
    enabled: false
```

如果要启用 Oh My Codex：

```yaml
orchestrator:
  provider: oh-my-codex
  mode: team-pipeline

integrations:
  oh_my_codex:
    enabled: true
    mode: adapter
    config: .agentflow/integrations/oh-my-codex.yml
```

未来也可以替换成其他 orchestrator，只要它能读取 `dispatch.md`，并把结果写回 `records/` 或 `results/`。

## Records

运行时协作只走 subagent，不使用 CCB inbox/outbox 协议。但保留类似 CCB 的留档纪律：

```text
project-docs/records/dispatch/
project-docs/records/done/
project-docs/records/review/
project-docs/records/test/
features/FEATURE-XXX-*/archive.md
```

其中：

- `dispatch` 会生成 dispatch record
- `archive` 会生成 review/test/done summary records
- 这些 records 用来给 Manager 和后续 Agent 提供稳定的项目级摘要入口
- 只有 summary records 也通过检查时，feature 状态才会从 `archive` 进入 `done`

推荐策略：

- `features/FEATURE-XXX-*/spec.md`、`plan.md`、`tasks.md`、`implementation/review.md`、`implementation/test.md`、`results/fix.md`、`archive.md` 是 durable knowledge，默认应进入 Git。
- `project-docs/records/review/`、`project-docs/records/test/`、`project-docs/records/done/` 是项目级 summary records，默认应进入 Git。
- `.agentflow/state/features.yml` 是 task board 的 canonical state，默认应进入 Git。
- `.agentflow/state/` 下其他文件是生成态 runtime state，默认不进入 Git。
- `project-docs/records/dispatch/` 是高频 dispatch log，默认按 transient 处理；如果团队需要审计完整派发历史，可以主动移出 `.gitignore`。

## Git Hygiene

推荐把文件分成两类：

- Durable knowledge:
  `spec.md`、`plan.md`、`tasks.md`、`implementation/review.md`、
  `implementation/test.md`、`results/fix.md`、`archive.md`、以及
  `project-docs/records/done|review|test/`、`.agentflow/state/features.yml`
- Transient runtime state:
  `.agentflow/state/*`（除 `features.yml`）、`project-docs/records/dispatch/`

默认初始化会把这些高频运行态路径加入 `.gitignore`：

```text
.agentflow/state/*
!.agentflow/state/features.yml
project-docs/records/dispatch/
.DS_Store
```

这样可以减少：

- 高频 context/state 更新带来的 Git 噪音
- dispatch 日志反复变化带来的冲突
- 临时运行态文件污染提交历史

每份记录应该尽量包含：

- 输入
- 输出
- 修改文件
- 验证结果
- 风险
- 下一步动作

## Migration From Markdown-Only Projects

已有项目如果已经有 `AGENTS.md`、`project-docs/` 或 feature bundle，可以按这个顺序迁移到 runtime guardrails：

1. 运行 `agentflow init --profile standard`，保留已有项目文档，不覆盖已有业务代码。
2. 确认 `agentflow.config.yml` 中的 `project.feature_dir` 和 `project.docs_dir` 指向现有目录。
3. 给每个 feature 补齐 `spec.md`、`plan.md`、`tasks.md`、`dispatch.md`、`implementation/`、`results/` 和 `archive.md`。
4. 执行 `agentflow feature status FEATURE-XXX-*`，让 runtime 报出真实缺口。
5. 从最早的阻塞阶段开始补齐占位符、review verdict、checklist 和 records。
6. 用 `agentflow feature next FEATURE-XXX-*` 推进，直到进入 `archive` 或 `done`。
7. 如果已有手写 task board，把需要保留的行迁移到 `.agentflow/state/features.yml`，再运行 `agentflow board render`。
8. 如果项目需要更强审查，把 `review.<stage>.mode` 从 `self` 调整为 `separate-session` 或 `human`。

迁移时不要一次性追求所有历史 feature 完美通过。优先让当前正在开发的 feature 通过 `spec -> plan -> tasks`，再逐步补历史记录。

## Current Status

当前版本已经提供：

- CLI 初始化器
- `lite / standard / full` 三档 profile
- `AGENTS.md` 模板
- 项目级文档模板
- feature bundle 模板
- YAML-driven feature generation and checks
- `check`、`gate`、`verify` 职责拆分
- `feature verify`、`feature gate`、`feature context`
- `feature next` 和 `feature status` 日常推进命令
- Markdown + JSON active context
- state-backed task board rendering
- review isolation and CLI approval metadata
- 轻量 hook 系统
- 角色定义
- vendored Superpowers-style skills
- Oh My Codex adapter 配置模板
- records 留档结构

当前还没有真正自动执行：

- spec-kit 命令
- Oh My Codex runtime
- 自动 spawn 所有 subagent
- 数据库或后台 daemon

这些会作为下一步 adapter 能力继续接入。当前稳定核心是项目初始化结构和 Feature Bundle 合同。
