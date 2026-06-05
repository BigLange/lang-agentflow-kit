# Lang AgentFlow Kit 介绍

Lang AgentFlow Kit 是一个面向 AI 辅助开发的项目初始化工具，用于在本地项目中生成一套 subagent-first 的协作架构。

它的目标是把 AI 开发中的项目规则、角色分工、阶段产物、任务留档、runtime gate 和可选编排配置标准化，让项目在开始开发前就具备清晰的协作结构。

## 核心定位

Lang AgentFlow Kit 不是传统意义上的业务脚手架。它不会直接生成某个框架的业务代码，而是生成一套 AI 开发协作层。

初始化后，项目会获得：

```text
AGENTS.md
agentflow.config.yml
.agentflow/
project-docs/
features/
```

其中：

- `AGENTS.md` 是 AI 的入口规则文件，定义角色、边界和协作原则。
- `.agentflow/` 存放角色定义、模板、skills 和可选集成配置。
- `project-docs/` 存放项目上下文、架构、API、任务板和 records。
- `features/` 存放 feature 级别的 spec、plan、tasks、dispatch、results 和 archive。

稳定核心分成两层：

- Markdown 协议层：`AGENTS.md`、`project-docs/`、feature bundle 和 records。
- 轻量 runtime 守卫层：`agentflow feature verify`、`gate`、`context`、`next` 和 `status`。

当前 `0.6.0` 版本继续推进工程守卫能力：feature state 已下沉到各 feature 目录，
任务板成为可重建的生成文件，并补充了 dynamic workflow、doctor、CI/hooks/rules
入口和外部模块准入治理。也就是说，AgentFlow 不再只是生成 Markdown 模板，而是在
保留 Markdown 灵活性的前提下，把关键流程变成可执行、可检查、可交接的本地协议。

## 安装方式

当前可以通过 GitHub 安装：

```bash
npm install -g github:BigLange/lang-agentflow-kit
```

进入任意项目后执行：

```bash
agentflow init --profile standard
```

即可生成项目本地的 AgentFlow 协作结构。

## 三种初始化模式

Lang AgentFlow Kit 提供三种初始化 profile：

```bash
agentflow init --profile lite
agentflow init --profile standard
agentflow init --profile full
```

更完整的当前配置字段说明，见：

- `docs/config-schema.md`

### lite

`lite` 是最轻量的初始化模式。

它包含：

- AgentFlow 核心结构
- `AGENTS.md`
- 项目级文档
- feature 模板
- records 留档目录

适合小项目、实验项目，或者只需要最小规则层的场景。

### standard

`standard` 是默认推荐模式。

它包含 `lite` 的全部内容，并额外加入项目本地的 Superpowers-style skills。

这些 skills 用于支持：

- 需求澄清
- 计划编写
- subagent-driven development
- TDD
- 代码审查
- 系统化修复
- 分支收口

适合大多数正式项目。

### full

`full` 是完整模式。

它包含 `standard` 的全部内容，并额外生成：

```text
.agentflow/integrations/oh-my-codex.yml
```

该文件用于描述 Oh My Codex 风格的团队编排流水线。

`full` 适合需要接入外部 orchestrator、多 Agent 团队编排，或者希望保留后续替换编排器空间的项目。

## 新项目流程

对于一个全新项目，推荐流程不是直接创建 feature，而是先初始化项目协作结构：

```bash
agentflow init --profile standard
```

然后围绕项目本身补齐项目级文档：

```text
project-docs/00_PROJECT_CONTEXT.md
project-docs/01_ARCHITECTURE.md
project-docs/02_API_SPEC.md
project-docs/03_TASK_BOARD.md
```

推荐阶段如下：

```text
项目澄清
-> 项目上下文
-> 架构/API 边界
-> 初始任务板
-> Feature 拆分
-> Feature 级 spec / plan / tasks
-> subagent 实施
-> 测试验证
-> 代码审查
-> 问题修复
-> 归档留档
```

这种方式适合从零开始构建项目，因为它先建立项目级方向，再拆分具体功能。

## Feature 流程

当项目级上下文已经明确后，可以使用：

```bash
agentflow feature create "user auth"
```

该命令会生成一个 feature bundle：

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
│   ├── frontend.md
│   └── mobile.md
└── archive.md
```

feature bundle 用于承载单个功能从需求到实现再到归档的完整链路。

实际生成哪些 review 文件、哪些实现端结果文件，由 `agentflow.config.yml` 的
effective config 决定。例如：

- `gates.require_spec_review: false` 时，不生成、不检查 `spec-review.md`。
- `gates.require_plan_review: false` 时，不生成、不检查 `plan-review.md`。
- `gates.require_task_review: false` 时，不生成、不检查 `task-review.md`。
- `implementation.target_sides: [backend]` 时，只生成并检查 backend result，不再因为
  frontend/mobile result 缺失而阻塞 gate。

这个改进的直接收益是：配置不再只是说明文档。项目可以根据真实技术形态裁剪流程，
CLI 也会按同一份配置生成、检查和阻断，减少“模板有但项目不用”“配置关闭但 gate
还在报错”的摩擦。

日常推进推荐使用：

```bash
agentflow feature next FEATURE-001-user-auth
agentflow feature status FEATURE-001-user-auth
```

`next` 会根据当前状态尝试推进下一步；`status` 会输出当前阶段、下一道 gate、任务完成度、records 状态和主要 blocker。

## Runtime Guardrails

当前 runtime 阶段模型是：

```text
draft -> spec -> plan -> tasks -> dispatch -> implement -> test -> review -> fix -> archive -> done
```

其中：

- `verify` 检查某个阶段是否完成。
- `check` 检查 feature bundle 结构、配置要求的文件和明显占位符。
- `gate` 检查某个阶段是否可以通过，不写状态、不同步任务、不归档。
- `context` 生成 `.agentflow/state/active_context.md` 和 `.agentflow/state/active_context.json`，帮助 Agent 在长任务前刷新当前工作视图。
- `status` 汇总 feature 的真实 runtime 状态。
- `next` 把 gate、task sync、context refresh 和状态输出串起来，作为默认日常命令。

这套 guardrails 不是要替代 Markdown，而是让 Markdown 合同变成可执行的阶段约束。

推荐的调试命令面是：

```bash
agentflow check FEATURE-001-user-auth
agentflow gate spec FEATURE-001-user-auth
agentflow gate plan FEATURE-001-user-auth
agentflow feature context FEATURE-001-user-auth
```

这样做的好处是：

- `check` 只回答结构是否完整，适合快速发现缺文件和模板残留。
- `gate` 只回答阶段能不能过，输出稳定的 `Gate Decision` 和 `Blockers`。
- `next` 才负责推进流程，因此不会因为一次“只想看看 gate”的操作意外同步状态或写 records。
- Agent 接手长任务时可以先读 `active_context.md`，再打开被引用的少量文件，减少从长文档里重新摸索上下文。

`active_context.md` 会以固定工作合同开头：

```text
This is the current working contract.
Start from this file before doing any work.
Do not start coding before checking the current gate.
Only open additional docs/files when this context references them or the current task requires verification.
```

这让后续操作更可控：新的 Agent 不需要先翻完整 README、全部 feature 文件和历史记录，而是先读一个短上下文，确认当前 gate、必读文件、禁止动作和下一步。

## State-backed Task Board

`project-docs/03_TASK_BOARD.md` 现在是渲染结果，不再是 feature 状态源数据。源数据在：

```text
.agentflow/state/features.yml
```

重新渲染任务板：

```bash
agentflow board render
```

`feature create` 和 `feature archive` 会更新 `features.yml` 并重新渲染 Markdown board。
如果需要人工修正任务板状态，应编辑 `features.yml`，再运行 `agentflow board render`。

这个改进解决的是长期项目里常见的 Markdown 表格问题：

- 表格手改容易破坏格式。
- 多人或多 Agent 同时追加 Markdown 行容易冲突。
- runtime 很难稳定解析任意手写 Markdown。
- state 文件更适合作为机器可读源数据，Markdown 则继续保留为人类可读视图。

后续操作的收益是：Manager 可以把 `features.yml` 当作项目状态数据源，把
`03_TASK_BOARD.md` 当作随时可重建的展示层。任务板坏了可以重新 render，而不是人工修表。

## Review Isolation

`0.5.0` 加入了 review isolation。它不是自动生成多个 reviewer，而是先在协议层防止
“自己写、自己无声批准”。

配置示例：

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

支持三种模式：

- `self`：兼容默认模式，当前会话可以自审，但 gate 会输出弱隔离 warning。
- `separate-session`：review 文件必须包含外部 review metadata，例如
  `review_mode: separate-session`、`reviewer: external`、`decision`、
  `blocking_issues: 0` 和 `reviewed_at`。
- `human`：必须通过 CLI 写入批准元数据：

```bash
agentflow approve FEATURE-001-user-auth --stage spec
```

这个改进的收益是：项目可以按风险分层控制 review 强度。低风险阶段保留 self review
的低成本；高风险实现审查可以要求 human approval；需要独立 AI session 审查的阶段可以
要求 separate-session metadata。gate 会把缺失的批准或外部审查明确报出来，避免 review
文件只是“看起来存在”。

## Subagent-first 架构

Lang AgentFlow Kit 默认采用 subagent-first 的协作方式。

主 Agent 作为 Manager，负责：

- 维护项目状态
- 读取项目文档
- 拆解任务
- 派发 subagent
- 汇总结果
- 更新 records
- 归档 feature
- 使用 `agentflow feature status` 和 `agentflow feature gate` 作为阶段状态的 source of truth

具体实现、测试、审查和修复则交给独立 subagent。

典型角色包括：

- Spec Creator
- Spec Reviewer
- Plan Creator
- Plan Reviewer
- Task Creator
- Task Reviewer
- API Designer
- Backend Implementer
- Frontend Implementer
- Mobile Implementer
- Test Agent
- Code Reviewer
- Fix Agent
- Commit Agent

小功能通常只需要 2 到 4 个 subagent。中等功能可能需要 4 到 8 个。长任务或多端任务可能需要 6 到 10 个以上。

## Superpowers-style skills

在 `standard` 和 `full` 模式中，Lang AgentFlow Kit 会把轻量版 Superpowers-style skills 复制到项目中：

```text
.agentflow/skills/
```

映射关系如下：

| AgentFlow Role | Skill Method |
| --- | --- |
| Spec Creator | `brainstorming` |
| Plan Creator | `writing-plans` |
| Manager / Implementation Flow | `subagent-driven-development` |
| Code Reviewer | `requesting-code-review` |
| Test Agent | `test-driven-development` |
| Fix Agent | `systematic-debugging` |
| Commit Agent | `finishing-a-development-branch` |

这些 skills 是项目本地副本，可以根据项目需要修改，不依赖全局安装。

## Oh My Codex Adapter

在 `full` 模式中，Lang AgentFlow Kit 会生成 Oh My Codex adapter 配置：

```text
.agentflow/integrations/oh-my-codex.yml
```

该配置描述了一条团队流水线：

```text
spec -> plan -> tasks -> api -> implement -> test -> review -> fix -> archive
```

Oh My Codex 在 Lang AgentFlow Kit 中不是硬编码依赖，而是一个可替换 adapter。

稳定的中间层是：

```text
features/FEATURE-XXX-*/dispatch.md
project-docs/records/
features/FEATURE-XXX-*/results/
```

只要新的 orchestrator 能读取 `dispatch.md`，并把执行结果写回 `records/` 或 `results/`，就可以替换 Oh My Codex。

## Records 留档

Lang AgentFlow Kit 不使用 CCB inbox/outbox 通信协议，但保留类似的留档纪律。

默认 records 位置包括：

```text
project-docs/records/dispatch/
project-docs/records/done/
project-docs/records/review/
project-docs/records/test/
features/FEATURE-XXX-*/archive.md
```

每份记录建议包含：

- 输入
- 输出
- 修改文件
- 验证结果
- 风险
- 下一步动作

通过 records，项目可以保留任务来源、执行结果、审查结论和验证状态。

推荐 Git 策略：

- durable knowledge 进入 Git：spec、plan、tasks、test/review summary、done summary 和 archive。
- task board state 进入 Git：`.agentflow/state/features.yml`。
- transient runtime state 不进入 Git：`.agentflow/state/*` 中除 `features.yml` 之外的文件。
- dispatch records 默认按高频 transient log 处理；需要审计派发历史的项目可以选择纳入 Git。

## 迁移已有项目

已有 Markdown-only 项目可以渐进迁移：

1. 初始化或补齐 `agentflow.config.yml`。
2. 确认 `features/` 和 `project-docs/` 路径正确。
3. 给当前正在开发的 feature 补齐标准 bundle 文件。
4. 运行 `agentflow feature status FEATURE-XXX-*`，让 runtime 报出真实缺口。
5. 从最早 blocker 开始补齐占位符、review 状态、checklist 和 records。
6. 使用 `agentflow feature next FEATURE-XXX-*` 推进到 `archive` 或 `done`。

迁移重点是先让当前 active feature 被 runtime 正确理解，不要求一次性修复所有历史 feature。

## 当前能力边界

当前版本已经提供：

- CLI 初始化器
- 三种 profile
- `AGENTS.md` 模板
- 项目级文档模板
- feature bundle 模板
- runtime verify/gate/context
- YAML-driven feature generation and checks
- `check` / `gate` 语义拆分
- Markdown + JSON active context
- state-backed task board rendering
- review isolation and CLI approval metadata
- daily workflow commands: `feature create`、`feature next`、`feature status`
- optional hooks
- 角色定义
- Superpowers-style skills
- Oh My Codex adapter 配置模板
- records 留档结构

当前版本还没有自动执行：

- spec-kit 命令
- Oh My Codex runtime
- 自动 spawn 全部 subagent
- 数据库或后台 daemon

这些能力可以作为后续 adapter 继续接入。

## 总结

Lang AgentFlow Kit 提供的是一套项目本地 AI 协作基础设施。

它适合希望把 AI 开发流程从临时对话升级为结构化协作的项目，尤其适合长任务、多阶段、多角色、多端协作和需要长期留档的开发场景。
