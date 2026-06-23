# 下一阶段加固路线图

这份路线图记录 `0.2.0` runtime guardrails 发布后开始的加固路径，并已持续交付到 `1.0.0`。

目标不是增加更多概念、角色或模板。目标是让现有协议更难被绕过：

> YAML 应控制生成和检查。Gates 应阻止无效阶段转换。Active context 应减少长任务上下文漂移。State 应可被机器读取，Markdown 则从 state 渲染。

优先级：

1. YAML-driven execution
2. Gate system hardening
3. Active context hardening
4. State-backed board rendering
5. Review isolation
6. Optional small engine extraction

## TODO 1: 让 YAML 控制执行

### 目标

`agentflow.config.yml` 不能只是装饰性文件。如果某个 workflow piece 在配置中被关闭，CLI 就不能生成它、检查它或因为它阻塞。

### 工作项

- [x] 从项目根目录加载 `agentflow.config.yml`。
- [x] 配置缺失时回退到 built-in defaults。
- [x] 实现 effective config merging：

```text
default config + user config = effective config
```

- [x] 让 `create_feature` 根据 effective config 生成文件。
- [x] 让 `check` 从 effective config 推导 required files，而不是使用硬编码文件列表。
- [x] 如果 `gates.require_spec_review: false`，不生成也不要求 `spec-review.md`。
- [x] 如果 `implementation.target_sides: [backend]`，只生成并检查 backend implementation outputs。
- [x] 记录哪些 config keys 被 runtime enforced，哪些仍是描述性的。

### 示例

```yaml
gates:
  require_spec_review: false

implementation:
  target_sides:
    - backend
```

期望行为：

- 没有 `spec-review.md`
- 没有 spec review gate check
- 没有 frontend/mobile result files
- 没有 frontend/mobile check failures

## TODO 2: 拆分 Check 和 Gate 语义

### 目标

`check` 应验证 feature 结构。`gate` 应决定阶段是否可以推进。

### 建议命令

```sh
agentflow check FEATURE-001
agentflow gate spec FEATURE-001
agentflow gate plan FEATURE-001
agentflow gate tasks FEATURE-001
agentflow gate implement FEATURE-001
agentflow gate review FEATURE-001
agentflow gate archive FEATURE-001
```

兼容命令可以保留，但文档应清楚说明 canonical form。

### `check` 职责

- [x] Feature directory exists。
- [x] Config-required files exist。
- [x] Obvious placeholders are removed。
- [x] File structure is internally complete。

### `gate` 职责

- [x] 决定当前阶段是否允许推进。
- [x] 用稳定、agent-readable 的语言报告阻塞原因。
- [x] 除非明确请求，否则不修改 feature state。

### Gate Rules

#### spec gate

- [x] `spec.md` exists。
- [x] `spec.md` does not contain `TBD`。
- [x] Goal is explicit。
- [x] Scope is explicit。
- [x] Acceptance criteria exist。
- [x] 如果要求 spec review，review metadata passes。

#### plan gate

- [x] `plan.md` exists。
- [x] `plan.md` does not contain `TBD`。
- [x] Implementation approach exists。
- [x] Impact file list exists。
- [x] Risk analysis exists。
- [x] 如果要求 plan review，review metadata passes。

#### tasks gate

- [x] `tasks.md` exists。
- [x] `tasks.md` does not contain `TBD`。
- [x] At least one executable task exists。
- [x] Each task has an owner or execution role。
- [x] 如果要求 task review，review metadata passes。

#### implement gate

- [x] Required implementation result files exist。
- [x] Test file exists when tests are required。
- [x] Test result is not pending。
- [x] Test result is not only "not tested"。

#### review gate

- [x] Review file exists。
- [x] Review has a clear decision: `approved`, `rejected`, or `needs changes`。
- [x] Blocking issues prevent the gate from passing。

#### archive gate

- [x] `archive.md` exists。
- [x] Final result is summarized。
- [x] Change summary exists。
- [x] Test summary exists。
- [x] Remaining issues are documented。

## TODO 3: 加固 Active Context

### 目标

通过让 active context 成为 agent 工作前阅读的第一个文件，减少长任务上下文漂移。

### 命令

```sh
agentflow context FEATURE-001
```

### 输出

生成一个或两个文件：

```text
.agentflow/state/active_context.md
.agentflow/state/active_context.json
```

状态：

- [x] 生成 `.agentflow/state/active_context.md`。
- [x] 继续生成 `.agentflow/state/active_context.json`。

### 必需内容

active context 应保持简短。它应包含：

```text
Feature:
Current Stage:
Current Gate:
Goal:
Required Files:
Must Read:
Forbidden Actions:
Next Step:
Open Questions:
Related Code Files:
```

- [x] Include feature。
- [x] Include current stage。
- [x] Include current gate。
- [x] Include goal。
- [x] Include required files。
- [x] Include must-read files。
- [x] Include forbidden actions。
- [x] Include next step。
- [x] Include open questions。
- [x] Include related code files。

### 必需头部

```text
This is the current working contract.
Start from this file before doing any work.
Do not start coding before checking the current gate.
Only open additional docs/files when this context references them or the current task requires verification.
```

- [x] 添加必需 active context header。

active context 是当前任务入口，不是唯一事实来源。Agent 应先读它，再按需要打开引用的 docs 和 code。

## TODO 4: State-backed Board Rendering

### 问题

直接往 `project-docs/03_TASK_BOARD.md` 追加行，会让任务板成为脆弱的数据源：

- Markdown tables 可能损坏。
- Git conflicts 很可能发生。
- Runtime 很难可靠解析。

### 目标

State 是源数据。Markdown 是渲染视图。

### State 文件

```text
.agentflow/state/features.yml
```

示例：

```yaml
features:
  - id: FEATURE-001
    title: User Auth
    stage: plan
    status: pending
    owner: Manager
    updated_at: 2026-05-27
```

### 命令

```sh
agentflow board render
```

职责：

- [x] 读取 `.agentflow/state/features.yml`。
- [x] 重新生成 `project-docs/03_TASK_BOARD.md`。
- [x] 将 Markdown 视为输出，而不是 canonical state。

## TODO 5: Review Isolation

### 目标

防止 self-review 静默批准高风险阶段。

当前不需要完整 multi-agent runtime。先从协议层 metadata 和 gate checks 开始。

### 配置形状

```yaml
review:
  spec:
    mode: separate-session
  plan:
    mode: self
  tasks:
    mode: self
  implementation:
    mode: human
```

支持模式：

- `self`
- `separate-session`
- `human`

### `self`

当前 AI 可以审查自己的工作。Gate 应将其标记为 weak review。仅用于低风险阶段。

### `separate-session`

Review 必须在独立 AI session 中完成。Review 文件必须包含 metadata：

```yaml
review_mode: separate-session
reviewer: external
decision: approved
blocking_issues: 0
reviewed_at: 2026-05-27
```

如果 metadata 缺失或无效，gate 必须失败。

- [x] 从 config 读取 `review.mode`。
- [x] gates 检查 `separate-session` review metadata。

### `human`

需要人工批准。不要允许 AI 手写 human sign-off。

命令：

```sh
agentflow approve FEATURE-001 --stage spec
```

该命令写入 approval metadata：

```yaml
approved_by: local-user
approved_at: 2026-05-27T12:00:00
approval_source: cli
```

Gate 检查这些 metadata。

- [x] `agentflow approve FEATURE --stage <stage>` 写入 CLI approval metadata。
- [x] `human` review mode 要求 CLI approval metadata。

## TODO 6: 暂不做

- 不添加更多角色。
- 不添加更复杂模板。
- 不构建完整 runtime platform。
- 不自动 spawn 多个 agents。
- 不添加数据库。
- 不把 YAML 变成复杂 DSL。
- 不为小任务削弱核心 workflow。
- 不立即全部改写成 Node 或 Python。

## TODO 7: 技术实现路线

目前保留 `bin/agentflow` 作为 CLI entrypoint。

当逻辑复杂到 shell 难以承载时，逐步抽取一个小 engine。

可能的 Node 结构：

```text
lang-agentflow-kit/
  bin/
    agentflow
  engine/
    config.js
    gate.js
    context.js
    board.js
```

可能的 Python 结构：

```text
lang-agentflow-kit/
  bin/
    agentflow
  agentflow_engine/
    config.py
    gate.py
    context.py
    board.py
```

不要把 engine code 复制到每个用户的 `.agentflow/engine/` 目录。

用户项目只应保留 project-local state 和 configuration：

```text
.agentflow/
  config.yml
  state/
```

工具代码应随 `lang-agentflow-kit` 自身升级。

## 推荐版本路线

当前发布版本是 `1.1.1`。下面较旧的 “v0.2: YAML truly controls execution” 说明作为历史路线规划保留。

### v0.2.x: YAML Truly Controls Execution

- [x] Read config。
- [x] Merge default config。
- [x] Generate feature files from effective config。
- [x] Check files from effective config。

### v0.3: Gate System Hardening

- [x] Split `check` and `gate` semantics。
- [x] Add stage-specific gate commands。
- [x] Ensure each gate checks whether the stage can advance。

### v0.4: Active Context Hardening

- [x] Generate stronger active context。
- [x] Include current working contract header。
- [x] Reduce long-task context drift。

### v0.5: State + Board Render

- [x] Add `.agentflow/state/features.yml`。
- [x] Add `agentflow board render`。
- [x] Render Markdown board from state。

### v0.6: Review Isolation

- [x] Support `review.mode`。
- [x] Support `separate-session` metadata。
- [x] Support `agentflow approve`。

## 最终原则

Lang AgentFlow Kit 不面向能直接编码完成的微小改动。它的价值在于为复杂、长上下文、多阶段、多 agent 项目提供稳定协议、阶段 gate、上下文控制和执行顺序。

不要继续堆概念。要把现有协议加固到 agent 无法跳过 workflow 却仍通过 gate 的程度。
