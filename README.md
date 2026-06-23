# Lang AgentFlow Kit

当前版本：`1.1.1`

Lang AgentFlow Kit 是一个面向 AI 辅助软件项目的本地工作流初始化工具。它会创建以 subagent 为优先的项目结构、Markdown 工作合同，以及轻量级 CLI 守卫能力，让长期 AI 协作具备清晰的状态、交接点和审查检查点。

它适合复杂项目：agents、人、规格说明、计划、任务、测试、审查和归档记录需要在较长时间内保持一致。

## 它是什么

Lang AgentFlow Kit 是：

- 本地项目工作流初始化器
- 面向 AI 辅助开发的 Markdown 协议
- 轻量级 CLI 守卫系统
- subagent-first 的协作结构

## 它不是什么

它不是：

- 自动 agent runner
- 后台 daemon
- 完整多 agent 编排平台
- Codex / Claude Code / Gemini CLI 的替代品
- 主要面向一行小改动的工具

## 它解决什么问题

AI 辅助项目一旦跨越多个会话，往往会发生漂移：spec 没写完、plan 和 tasks 不一致、review 被跳过、任务板被手改坏，后续 agent 也不知道项目真实状态。

AgentFlow 给项目提供一份小而明确的本地合同：

- `AGENTS.md` 告诉 agent 如何在当前仓库工作。
- `project-docs/` 存放项目上下文、架构说明、API 说明、任务板和人工验收清单。
- `project-docs/ACTIVE_WORK.md` 记录当前 feature/task/stage，作为新会话恢复入口。
- `features/FEATURE-XXX-*` 存放 feature 级 spec、plan、tasks、模型路由、测试资产、results 和 archive。
- `agentflow` CLI 检查 gate、写入 active context、渲染任务板并报告状态。

## 适用场景

| 适合 | 不适合 |
| --- | --- |
| 长期 AI 辅助项目 | 一行小改动 |
| 重度使用 AI 的个人项目或小团队项目 | 临时实验 |
| 需要 spec、plan、test、review 和交接的工作 | 没有生命周期的脚本 |
| 多个 agent/session 可能接手同一个 feature 的项目 | 完全自动化 agent 平台 |

## 平台支持

| 平台 | 支持情况 |
| --- | --- |
| macOS | 支持 |
| Linux | 支持 |
| Windows | 使用 WSL 或 Git Bash |
| 原生 PowerShell | 暂未完整支持 |

说明：

- npm 主要用于安装和分发。
- package 安装要求 Node `>=18`。
- 当前 runtime 仍然是 Bash CLI。

## 安装

从 GitHub 安装：

```sh
npm install -g github:BigLange/lang-agentflow-kit
```

检查已安装版本：

```sh
agentflow --version
agentflow version
```

从源码 checkout 运行：

```sh
/path/to/lang-agentflow-kit/bin/agentflow --version
```

## 5 分钟快速开始

```sh
npm install -g github:BigLange/lang-agentflow-kit

mkdir demo-agentflow
cd demo-agentflow

agentflow init --profile standard
```

然后打开 AI 工具，对 Manager 说短句即可：

```text
帮我配置 AgentFlow。
帮我拆分这个项目，需求在 docs/requirements.md。
当前阶段完成，继续下一阶段。
```

Manager 会读取 `AGENTS.md`、`agentflow.config.yml`、`.agentflow/skills/agentflow-manager-workflow/SKILL.md` 和 `project-docs/ACTIVE_WORK.md`，缺信息时反问用户。导入需求后，Manager 会先生成 `project-docs/01_ARCHITECTURE.md` 架构建议，只反问会影响技术路线的问题；用户确认架构后，再提出 YAML 配置建议、识别可能导入的第三方模块、创建 feature、推进阶段、运行检查和更新状态。

背后会发生这些动作：

| 动作 | 作用 |
| --- | --- |
| `agentflow init --profile standard` | 创建 `AGENTS.md`、`agentflow.config.yml`、`.agentflow/`、`project-docs/` 和 `features/`。 |
| `agentflow architecture check` | 检查 `project-docs/01_ARCHITECTURE.md` 是否已确认且没有占位符。 |
| Manager 创建 feature bundle | 生成 `features/FEATURE-XXX/`、阶段文件和 `state.yml`。 |
| Manager 检查状态 | 确认当前阶段、下一道 gate、任务进度、records 和 blockers。 |
| Manager 推进阶段 | 如果 gate 通过就进入下一阶段；如果阻塞就解释原因并反问用户。 |

如果 gate 阻塞，这是正常情况。日常使用时让 Manager 解释 blocker、补齐文件或反问用户；不需要用户自己记住所有命令。

## 生成文件

`project-docs/03_TASK_BOARD.md` 是生成文件，请不要直接编辑。

Manager 会刷新状态并重建任务板。底层命令包括：

```sh
agentflow feature next FEATURE-001-customer-export
agentflow feature status FEATURE-001-customer-export
agentflow board render
```

生成的任务板会包含类似头部：

```md
<!--
GENERATED FILE: DO NOT EDIT DIRECTLY.
-->
```

feature 进度的事实来源是：

```text
features/FEATURE-XXX/state.yml
```

## 常用命令

这些命令主要给 Manager、hook 或排查问题时使用。普通用户日常可以说“继续开发”“当前阶段完成”“帮我拆项目”“加入模块”。

| 命令 | 用途 |
| --- | --- |
| `agentflow init --profile standard` | 在当前项目初始化 AgentFlow。 |
| `agentflow feature create "user auth"` | 创建新的 feature bundle。 |
| `agentflow feature status FEATURE-001-user-auth` | 查看 feature 状态和下一道 gate。 |
| `agentflow feature next FEATURE-001-user-auth` | 尝试推进下一步工作流。 |
| `agentflow architecture check` | 在完整项目拆分前检查架构文档是否已确认。 |
| `agentflow update --check` | 检查已有项目是否缺少当前版本的模板、配置段或 feature 文件。 |
| `agentflow update --apply` | 安全补齐缺失文件和配置段，不覆盖已有内容。 |
| `agentflow stage plan FEATURE-001-user-auth --stage spec --adapter codex` | 生成 spec/plan/tasks 等前置阶段的 Codex prompt。 |
| `agentflow dispatch plan FEATURE-001-user-auth --adapter codex` | 生成 Codex 子代理分派计划和 prompt。 |
| `agentflow dispatch run FEATURE-001-user-auth --adapter codex` | dry-run 显示 Codex 分派脚本；加 `--execute` 才执行。 |
| `agentflow board render --check` | 验证生成任务板是否最新。 |

更完整的 `gate`、`check`、`context`、外部模块治理和复用检查命令，请先看 [`docs/user-manual.md`](docs/user-manual.md)。

## 初始化 Profile

| Profile | 包含内容 | 适合 | 优点 | 代价 |
| --- | --- | --- | --- | --- |
| `lite` | 核心文件、`AGENTS.md`、项目文档、feature 模板、records、较轻 runtime | 只想要最小协议层的项目 | 小、易采用 | 流程指导较少 |
| `standard` | `lite` 全部内容，加上 vendored Superpowers-style skills | 大多数长期 AI 辅助项目 | 默认平衡最好 | 对很小任务偏重 |
| `full` | `standard` 全部内容，加上可选 Oh My Codex adapter 配置 | 准备接入外部编排的项目 | 模板最完整 | 更重；不是自动 orchestrator |

推荐默认值：

```sh
agentflow init --profile standard
```

## Feature 类型

类型是 feature 级别的流程强度，不是 task 级标签。完整项目可能有数百个 task，但通常只需要确认几十个 feature 的类型。

| 类型参数 | 中文说明 | 适合场景 |
| --- | --- | --- |
| `trivial` | 极小改动 | 文案、样式、配置、小范围调整 |
| `bug` | 缺陷修复 | 已知问题修复，需要补测试或验证记录 |
| `standard` | 标准功能 | 普通业务功能，默认选择 |
| `major` | 复杂功能 | 多模块、多端协作、影响范围较大的功能 |
| `sensitive` | 敏感/高风险功能 | 用户、权限、认证、支付、文件上传、加密、租户隔离、外部模块复用 |

如果不确定，先用 `standard`。涉及安全、权限、支付、用户数据时用 `sensitive`。各类型对应的完整阶段列表见 [`docs/config-schema.md`](docs/config-schema.md)。

## 外部模块治理

AgentFlow 可以注册并 gate 外部模块，但不会下载或复制它们的代码。公共模块默认不可信，auth、user、permission、payment、crypto、file upload、admin account、tenant isolation 等敏感领域会被视为高风险。

典型流程：

```sh
agentflow module add public-admin-template \
  --name "Public Admin Template" \
  --source-type public \
  --source github:example/admin-template \
  --module-type template \
  --domain admin \
  --risk high \
  --mode reference-only

agentflow module contract public-admin-template
agentflow reuse analyze FEATURE-001-admin-user-permission
agentflow reuse gate FEATURE-001-admin-user-permission
```

生成的治理文件：

```text
.agentflow/modules/external_modules.yml
.agentflow/modules/external_module_policy.yml
.agentflow/modules/MODULE_ID/module-contract.yml
.agentflow/modules/MODULE_ID/security-notes.md
.agentflow/modules/MODULE_ID/integration-notes.md
features/FEATURE-XXX/reuse-analysis.md
features/FEATURE-XXX/external-module-risk.md
```

安全边界：

- AgentFlow 不下载公共仓库。
- AgentFlow 不自动复制或 vendor 公共代码。
- 公共关键领域模块默认只能 reference-only。
- 公共 `direct-copy` 会被阻止。
- 公共 high/critical `vendor` 需要明确人工批准。

## 核心输出

典型初始化后的项目：

```text
AGENTS.md
agentflow.config.yml
.agentflow/
  modules/
    external_modules.yml
    external_module_policy.yml
project-docs/
  00_PROJECT_CONTEXT.md
  01_ARCHITECTURE.md
  02_API_SPEC.md
  03_TASK_BOARD.md
  04_MANUAL_ACCEPTANCE.md
  ACTIVE_WORK.md
features/
  FEATURE-001-customer-export/
    state.yml
    spec.md
    plan.md
    tasks.md
    model-routing.md
    test-cases.md
    test-results.md
    manual-acceptance.md
    implementation/
    results/
    archive.md
```

<details>
<summary>active_context.md 示例</summary>

```md
# Active Context

Current Feature: FEATURE-001-customer-export
Current Stage: plan
Next Gate: tasks

Must Read:
- AGENTS.md
- features/FEATURE-001-customer-export/spec.md
- features/FEATURE-001-customer-export/plan.md

Do Not:
- edit generated files directly
- skip gate checks
```

</details>

<details>
<summary>feature state.yml 示例</summary>

```yaml
id: "FEATURE-001-customer-export"
title: "customer export"
type: "standard"
stage: "draft"
status: "pending"
mode: "subagent"
owner: "Manager"
verified: "no"
notes: "Created by agentflow feature create"
updated_at: "2026-06-05"
```

</details>

## 当前能力

- 初始化本地 AgentFlow 项目结构。
- 从模板生成 feature bundle。
- 在 `features/FEATURE-XXX/state.yml` 中维护每个 feature 的状态。
- 从 feature state 渲染 `project-docs/03_TASK_BOARD.md`。
- 检查 feature gate 并报告 blockers。
- 在完整项目拆分前生成并确认 `project-docs/01_ARCHITECTURE.md`，用
  `agentflow architecture check` 检查架构状态。
- 生成用于 agent 交接的 active context。
- 生成 feature 级 AI 测试用例/结果，并维护项目级人工验收清单。
- 生成 feature/task 级模型路由建议，用 `low`、`medium`、`high`、`extra-high` reasoning 档位指导 subagent 分派。
- 生成 `project-docs/ACTIVE_WORK.md`，让 Manager 可以跨会话恢复当前 feature/task/stage。
- 通过 `agentflow doctor` 运行本地健康检查。
- 生成 warning-mode Git hooks 和 GitHub Actions 模板。
- 生成基础 Cursor / Cline / Codex 规则文件。

## 当前限制

- 它不是自动 Agent runner。
- 它不能真正自行 spawn subagents。
- Git hooks / CI enforcement 当前是轻量且 warning-first 的。
- 如果存在旧全局 state，它只作为缓存/索引数据；feature state 位于 `features/FEATURE-XXX/state.yml`。
- 外部公共模块复用只做治理；不要自动把公共 auth、permission、payment、upload、crypto 或 admin-account 模块复制进项目。
- 原生 Windows PowerShell 支持有限；请使用 WSL 或 Git Bash。
- runtime 有意保持 Bash-based 和确定性，不是完整 YAML schema engine。

## 详细文档

| 主题 | 链接 |
| --- | --- |
| 产品介绍 | [`docs/lang-agentflow-kit-introduction.md`](docs/lang-agentflow-kit-introduction.md) |
| 使用说明手册 | [`docs/user-manual.md`](docs/user-manual.md) |
| 配置快速指南 | [`docs/config-guide.md`](docs/config-guide.md) |
| 配置字段参考 | [`docs/config-schema.md`](docs/config-schema.md) |
| Runtime guardrails TODO | [`docs/runtime-guardrails-todo.md`](docs/runtime-guardrails-todo.md) |
| 下一阶段加固路线图 | [`docs/next-stage-hardening-roadmap.md`](docs/next-stage-hardening-roadmap.md) |
| 变更日志 | [`CHANGELOG.md`](CHANGELOG.md) |

## 开发

```sh
npm run check
npm run smoke
npm run pack:check
```
