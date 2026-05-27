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
- `gate` 检查能否进入下一个阶段。
- `context` 生成 `.agentflow/state/active_context.json`，帮助 Agent 在长任务前刷新当前工作视图。
- `status` 汇总 feature 的真实 runtime 状态。
- `next` 把 gate、task sync、context refresh 和状态输出串起来，作为默认日常命令。

这套 guardrails 不是要替代 Markdown，而是让 Markdown 合同变成可执行的阶段约束。

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
- transient runtime state 不进入 Git：`.agentflow/state/`。
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

这些能力可以作为后续 adapter 继续接入。

## 总结

Lang AgentFlow Kit 提供的是一套项目本地 AI 协作基础设施。

它适合希望把 AI 开发流程从临时对话升级为结构化协作的项目，尤其适合长任务、多阶段、多角色、多端协作和需要长期留档的开发场景。
