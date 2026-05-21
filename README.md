# Lang AgentFlow Kit

Lang AgentFlow Kit 是一个本地项目初始化工具，用来给项目生成一套
**subagent-first** 的 AI 开发协作架构。

它吸收了几类体系的优点：

- spec-kit 的阶段化产物：`spec.md`、`plan.md`、`tasks.md`
- Superpowers 的工作方法：需求澄清、写计划、TDD、代码审查、系统化修复
- Oh My Codex 的团队编排思路：作为可替换的 orchestrator adapter
- 你自己的留档体系：任务板、dispatch、done、review、test、archive records

核心目标是：安装一次，进入任意项目执行 `agentflow init`，然后就可以直接和 AI 对话。项目里会提前生成 `AGENTS.md`、项目文档、角色定义、模板、skills、records 和可选集成配置。

## 安装

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

## 三种初始化模式

| 模式 | 包含内容 | 适合场景 | 优点 | 缺点 |
| --- | --- | --- | --- | --- |
| `lite` | AgentFlow 核心文件、`AGENTS.md`、项目文档、feature 模板、records | 小项目、实验项目、只想要最小规则层 | 文件少、心智负担低、初始化轻 | gate 少；不内置 Superpowers；不生成 Oh My Codex 配置 |
| `standard` | `lite` 全部内容 + 本地 vendored Superpowers-style skills | 默认推荐，适合大多数认真开发的项目 | 有完整角色和方法论；仍然不太重；适合 Codex subagents | 比 `lite` 多一些流程和检查 |
| `full` | `standard` 全部内容 + `.agentflow/integrations/oh-my-codex.yml` | 想接 Oh My Codex 或其他团队编排器的项目 | 最完整；具备外部 orchestrator adapter 位置 | 最重；Oh My Codex 只是配置好 adapter，不代表已真正运行 |

推荐默认使用：

```sh
agentflow init --profile standard
```

什么时候选：

- 想轻量试用：`lite`
- 想认真做项目：`standard`
- 想接 Oh My Codex / 多 Agent 团队编排：`full`

## init 会生成什么

```text
AGENTS.md
agentflow.config.yml
.agentflow/
  agents/
  templates/
  skills/                 # standard/full 才有
  integrations/           # full 会包含 oh-my-codex.yml
project-docs/
  00_PROJECT_CONTEXT.md
  01_ARCHITECTURE.md
  02_API_SPEC.md
  03_TASK_BOARD.md
  records/
features/
```

其中 `AGENTS.md` 是 AI 入口文件。初始化后，如果是新项目，应该先和 AI 讨论项目目标、用户、技术栈、边界和架构，而不是马上执行 `agentflow feature`。

## 新项目流程

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

## Feature 流程

`agentflow feature "..."` 适合已有项目新增功能，或者项目级上下文已经明确之后拆出来的功能。

示例：

```sh
agentflow feature "用户登录"
agentflow dispatch FEATURE-001-feature
agentflow archive FEATURE-001-feature
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
│   ├── frontend.md
│   └── mobile.md
└── archive.md
```

## 整体阶段

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

## 会启动多少个 subagent

实际数量取决于任务大小。推荐的逻辑角色如下：

| 阶段 | Subagent 角色 | 预期数量 |
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

## Superpowers 集成

`standard` 和 `full` 会把轻量版 Superpowers-style skills 复制到项目内：

```text
.agentflow/skills/
```

映射关系：

| AgentFlow 角色 | 使用的方法论 |
| --- | --- |
| Spec Creator | `brainstorming` |
| Plan Creator | `writing-plans` |
| Manager / 实施编排 | `subagent-driven-development` |
| Code Reviewer | `requesting-code-review` |
| Test Agent | `test-driven-development` |
| Fix Agent | `systematic-debugging` |
| Commit Agent | `finishing-a-development-branch` |

这些 skills 是项目本地副本，可以按项目修改，不依赖用户全局安装 Superpowers。

## Oh My Codex 集成与切换

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

## 留档方式

运行时协作只走 subagent，不使用 CCB inbox/outbox 协议。但保留类似 CCB 的留档纪律：

```text
project-docs/records/dispatch/
project-docs/records/done/
project-docs/records/review/
project-docs/records/test/
features/FEATURE-XXX-*/archive.md
```

每份记录应该尽量包含：

- 输入
- 输出
- 修改文件
- 验证结果
- 风险
- 下一步动作

## 当前状态

当前版本已经提供：

- CLI 初始化器
- `lite / standard / full` 三档 profile
- `AGENTS.md` 模板
- 项目级文档模板
- feature bundle 模板
- 角色定义
- vendored Superpowers-style skills
- Oh My Codex adapter 配置模板
- records 留档结构

当前还没有真正自动执行：

- spec-kit 命令
- Oh My Codex runtime
- 自动 spawn 所有 subagent

这些会作为下一步 adapter 能力继续接入。当前稳定核心是项目初始化结构和 Feature Bundle 合同。
