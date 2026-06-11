# AgentFlow 配置快速指南

这份文档解释配置在真实操作中什么时候生效。完整字段参考见 [config-schema.md](./config-schema.md)。

## 配置什么时候会起作用

配置通常在你运行 `agentflow` 命令时被读取。

| 你运行的命令 | 会用到的配置 | 实际影响 |
| --- | --- | --- |
| `agentflow feature create "xxx"` | `workflow.default_type`、`implementation.target_sides`、`gates.require_*` | 决定 feature 类型、生成哪些文件、是否生成 review 文件 |
| `agentflow feature status FEATURE-XXX` | `project.feature_dir`、`runtime.state_dir`、`gates.*` | 读取 feature 状态，计算当前阶段和 blocker |
| `agentflow feature next FEATURE-XXX` | `workflow`、`gates.*`、`hooks.*`、`runtime.*` | 尝试推进阶段，触发 gate 和 hook |
| `agentflow gate plan FEATURE-XXX` | `gates.require_plan_review`、`review.plan.mode` | 检查 plan 能不能过 |
| `agentflow feature context FEATURE-XXX` | `runtime.active_context_*` | 生成 AI 接手用的上下文文件 |
| `agentflow board render` | `project.docs_dir`、feature `state.yml` | 重新生成任务板 |
| `agentflow reuse gate FEATURE-XXX` | `external_module_policy` | 检查第三方模块复用风险 |

日常协作中，人不需要手动执行所有命令。推荐让 Manager 根据 `project-docs/ACTIVE_WORK.md` 自动运行这些检查，并在每轮结束输出配置中的心跳。默认是短行输出；只有 `manager.heartbeat_mode: full` 时才输出完整 `anchor_pulse`。

## 配置文件顶部注释给 AI 看

初始化后的 `agentflow.config.yml` 顶部会包含一段注释。它不是给 CLI 执行的，而是给 AI Manager 读的。

这段注释会提醒 Manager：

```text
1. 创建 feature 或继续工作前先读配置。
2. 从 project.docs_dir 找到 project-docs/ACTIVE_WORK.md。
3. 用户没指定 --type 时使用 workflow.default_type。
4. 根据 implementation.target_sides 判断需要 backend/frontend/mobile 哪些结果。
5. 根据 gates 和 review 判断哪些检查必须通过。
6. 尽量通过 hooks 执行重复检查，不要让人手动跑一堆命令。
7. 每轮结束更新 ACTIVE_WORK.md，并按 manager.heartbeat_mode 输出心跳。
```

这让新窗口里的人机协作可以很短：

```text
你是 Manager，请继续开发。
```

建议把“继续开发时先读 `AGENTS.md`、`agentflow.config.yml` 和 `project-docs/ACTIVE_WORK.md`”写进 `AGENTS.md`、`CLAUDE.md` 或其他 AI 工具的必读规则文件里。这样用户日常只需要一句短指令。

如果 AI 忘记这些规则，人的介入点不是手动补跑所有命令，而是要求它重新读取这三个文件。

默认心跳口令在配置里：

```yaml
manager:
  heartbeat_phrase: "AI为你保驾护航"
```

你可以把它改成任何容易识别的短句。Manager 每轮结束必须输出这个口令。

## 让 AI 修改配置的规则

`agentflow.config.yml` 里的中文注释既给人看，也给 AI Manager 看。它们的作用不是替代文档，而是让 AI 在初始化项目时知道哪些字段可以改、什么时候该改、改完要检查什么。

推荐让 AI 按这个顺序处理配置：

```text
1. 先读 AGENTS.md、agentflow.config.yml、需求文档和 project-docs/ACTIVE_WORK.md。
2. 只输出配置修改建议，不直接改文件。
3. 对每个建议说明：为什么改、改哪个字段、改完影响什么命令或 gate。
4. 等用户确认。
5. 修改 YAML。
6. 检查 YAML 语法，运行必要的 agentflow status/gate/check。
7. 把配置变更和检查结果写入 ACTIVE_WORK.md。
```

可以直接对 AI 说：

```text
帮我配置 AgentFlow。
```

Manager 应该反问缺失信息，给出 YAML 修改建议，等用户确认后再改。AI 不应该为了“看起来更严格”随意打开所有 gate，也不应该为了“用起来简单”随意关闭安全相关 gate。判断标准是项目风险，而不是字段越多越好。

## 常见配置场景

### 纯后端项目

如果项目没有前端和移动端，把 `target_sides` 改成只检查后端：

```yaml
implementation:
  target_sides:
    - backend
```

实际例子：

```sh
agentflow feature create "user auth"
agentflow check FEATURE-001-user-auth
agentflow gate implement FEATURE-001-user-auth
```

实际效果：

```text
1. 新 feature 只要求后端结果。
2. 不生成或不要求 results/frontend.md。
3. 不生成或不要求 results/mobile.md。
4. check/gate 不会因为缺少前端或移动端结果而失败。
```

### 前后端项目，没有移动端

```yaml
implementation:
  target_sides:
    - backend
    - frontend
```

实际效果：

```text
新 feature 会要求 backend 和 frontend 结果。
不会要求 mobile 结果。
```

适合 Web 项目，不适合同时有 App 的项目。

### 小项目减少审查文件

如果项目很小，想减少 `spec-review.md`、`plan-review.md`、`task-review.md` 的压力：

```yaml
gates:
  require_spec_review: false
  require_plan_review: false
  require_task_review: false
```

实际例子：

```sh
agentflow feature create "settings page"
agentflow gate spec FEATURE-001-settings-page
agentflow gate plan FEATURE-001-settings-page
agentflow gate tasks FEATURE-001-settings-page
```

实际效果：

```text
1. 新 feature 可以不生成 spec-review.md、plan-review.md、task-review.md。
2. gate 会检查 spec.md、plan.md、tasks.md 本身。
3. gate 不会因为 review 文件缺失而阻塞。
```

注意：关闭 review gate 会降低流程严格度。涉及用户、权限、支付、安全时不建议关闭。

### 默认创建更严格的 feature

如果项目大多数功能都比较复杂，可以把默认类型改成 `major`：

```yaml
workflow:
  default_type: major
```

如果项目主要是权限、支付、认证、租户隔离等高风险功能，可以改成：

```yaml
workflow:
  default_type: sensitive
```

实际例子：

```sh
agentflow feature create "user permission"
```

如果 `default_type: sensitive`，即使你没有写 `--type sensitive`，它也会按 sensitive 流程创建：

```text
spec -> reuse-risk -> plan -> tasks -> dispatch -> implement -> security-review -> test -> review -> fix -> archive
```

如果你只想某一次创建普通功能，可以显式覆盖：

```sh
agentflow feature create "help page" --type standard
```

## 一条完整流程里，配置如何生效

下面用 `FEATURE-001-user-auth` 举例，把常见配置串起来。

### 0. 新会话恢复时

你只需要说：

```text
你是 Manager，请读取 AGENTS.md 和 project-docs/ACTIVE_WORK.md，按当前状态继续开发。
```

Manager 应该读取：

```text
project-docs/ACTIVE_WORK.md
```

实际效果：

```text
1. 确认当前 feature、stage、task 和 owner role。
2. 查看上次已执行 checks 和 blocker。
3. 运行必要的 status/context/gate/check。
4. 从记录的 next action 继续，而不是重新规划。
5. 本轮结束前更新 ACTIVE_WORK.md 并按 manager.heartbeat_mode 输出心跳。
```

### 1. 创建 feature 时

你运行：

```sh
agentflow feature create "user auth"
```

CLI 会读取：

```yaml
workflow:
  default_type: standard

implementation:
  target_sides:
    - backend
    - frontend
    - mobile

gates:
  require_spec_review: true
  require_plan_review: true
  require_task_review: true
```

实际效果：

```text
1. 因为没有写 --type，所以使用 default_type: standard。
2. 因为 target_sides 有 backend/frontend/mobile，所以生成三端结果文件。
3. 因为 require_*_review 是 true，所以生成 spec-review.md、plan-review.md、task-review.md。
```

### 2. 查看状态时

你运行：

```sh
agentflow feature status FEATURE-001-user-auth
```

CLI 会读取：

```yaml
project:
  feature_dir: features

runtime:
  state_dir: .agentflow/state
```

实际效果：

```text
1. 到 features/FEATURE-001-user-auth/ 找 feature 文件。
2. 读取 state.yml 判断当前阶段。
3. 根据 gates 配置判断当前缺哪些文件或审查。
4. 输出当前 stage、next gate、progress 和 blockers。
```

### 3. 生成上下文时

你运行：

```sh
agentflow feature context FEATURE-001-user-auth
```

CLI 会读取：

```yaml
runtime:
  state_dir: .agentflow/state
  active_context_file: active_context.json
  active_context_markdown_file: active_context.md
```

实际效果：

```text
1. 生成 .agentflow/state/active_context.md。
2. 生成 .agentflow/state/active_context.json。
3. 告诉 AI 当前 feature、当前阶段、下一道 gate、必须阅读的文件和禁止动作。
```

### 4. 推进下一步时

你运行：

```sh
agentflow feature next FEATURE-001-user-auth
```

CLI 会读取：

```yaml
gates:
  require_plan_review: true

hooks:
  after_plan:
    - bin/agentflow feature context {{FEATURE}}

runtime:
  hook_failure_policy: stop
```

实际效果：

```text
1. 先检查 plan gate。
2. 如果 plan-review.md 没通过，停止推进。
3. 如果 plan gate 通过，触发 after_plan。
4. after_plan 会运行 bin/agentflow feature context FEATURE-001-user-auth。
5. 如果 hook 命令失败，hook_failure_policy: stop 会让本次推进停止。
```

### 5. 涉及第三方模块时

如果 feature 是：

```text
integrate user management module
```

并且类型是 `sensitive`，CLI 会关注：

```yaml
runtime:
  require_reuse_gate_for_sensitive: true

external_module_policy:
  public_default_mode: reference-only
  public_vendor_allowed: false
```

实际效果：

```text
1. 这个 feature 会被视为高风险。
2. 如果复用公共用户管理模块，默认只能 reference-only。
3. public_vendor_allowed: false 表示公共模块默认不能 vendor 进项目。
4. 你需要先运行 reuse analyze / reuse gate，再进入实现。
```

相关命令：

```sh
agentflow reuse analyze FEATURE-001-integrate-user-management-module
agentflow reuse gate FEATURE-001-integrate-user-management-module
```

### 6. 重新生成任务板时

你运行：

```sh
agentflow board render
```

CLI 会读取：

```yaml
project:
  docs_dir: project-docs
```

实际效果：

```text
1. 读取各 feature 的 state.yml。
2. 重新生成 project-docs/03_TASK_BOARD.md。
3. 任务板只是展示结果，不是状态源。
```

不要直接编辑：

```text
project-docs/03_TASK_BOARD.md
```

## Gate 生效例子

`gate` 可以理解成“阶段门禁”。

### 从 plan 推进到 tasks

假设你正在做：

```text
FEATURE-001-user-auth
```

当前已经写完 `spec.md`，正在补 `plan.md`。你运行：

```sh
agentflow feature next FEATURE-001-user-auth
```

CLI 会大致做这些事：

```text
1. 读取 features/FEATURE-001-user-auth/state.yml，确认当前阶段。
2. 判断下一步是否要进入 tasks。
3. 运行 plan gate，检查 plan 阶段是否满足条件。
4. 如果 plan.md 没写完、还有 TBD、缺风险分析，gate 会失败。
5. 如果配置要求 plan-review.md，通过前也会检查 plan-review.md。
6. gate 通过后，才允许进入下一阶段。
```

如果只想检查，不想推进状态，可以手动运行：

```sh
agentflow gate plan FEATURE-001-user-auth
```

### 为什么 archive 会被挡住

假设功能已经写完代码，但还没补测试记录。你运行：

```sh
agentflow gate archive FEATURE-001-user-auth
```

如果配置里有：

```yaml
gates:
  require_tests_before_done: true
  require_review_before_commit: true
```

那么 CLI 会检查测试和审查记录。如果 `implementation/test.md` 还是 pending，或者 `implementation/review.md` 没有明确通过，archive gate 就会失败。

这时你应该先补：

```text
features/FEATURE-001-user-auth/implementation/test.md
features/FEATURE-001-user-auth/implementation/review.md
```

再重新运行 gate。

## Hook 生效例子

Hook 是“在某个阶段前后自动跑的命令”。

### plan 通过后自动刷新上下文

配置：

```yaml
hooks:
  after_plan:
    - bin/agentflow feature context {{FEATURE}}
```

场景：

```text
你正在推进 FEATURE-001-user-auth。
plan gate 通过后，CLI 触发 after_plan。
after_plan 里的命令会把 {{FEATURE}} 替换成 FEATURE-001-user-auth。
最终执行：
bin/agentflow feature context FEATURE-001-user-auth
```

结果是：

```text
.agentflow/state/active_context.md
.agentflow/state/active_context.json
```

### 实现后自动跑测试

配置：

```yaml
hooks:
  after_implement:
    - npm test
```

场景：

```text
你完成实现后运行 agentflow feature next FEATURE-001-user-auth。
CLI 判断 implement 阶段完成，准备进入 test 或后续阶段。
这时触发 after_implement。
after_implement 会执行 npm test。
```

如果测试失败，会发生什么取决于：

```yaml
runtime:
  hook_failure_policy: stop
```

含义：

- `stop`：hook 失败就停止推进。适合正式项目。
- `warn`：只打印警告但继续。适合早期探索。

### 进入 dispatch 前先看状态

配置：

```yaml
hooks:
  before_dispatch:
    - bin/agentflow feature status {{FEATURE}}
```

场景：

```text
你准备从 tasks 进入 dispatch。
CLI 会先触发 before_dispatch。
它会打印当前 feature 状态，帮助你确认是否真的该进入分派阶段。
```

### Hook 占位符

| 占位符 | 会替换成 |
| --- | --- |
| `{{FEATURE}}` | 当前 feature ID，例如 `FEATURE-001-user-auth` |
| `{{FEATURE_DIR}}` | 当前 feature 目录 |
| `{{PROJECT_ROOT}}` | 项目根目录 |
| `{{STAGE}}` | 当前阶段 |

## 人工和独立审查例子

### 人工批准

配置：

```yaml
review:
  spec:
    mode: human
```

实际流程：

```text
1. AI 写完 spec.md。
2. 你运行 agentflow gate spec FEATURE-001-user-auth。
3. 如果还没有 approve 记录，gate 会失败。
4. 你人工确认 spec 没问题。
5. 运行 agentflow approve FEATURE-001-user-auth --stage spec。
6. 再运行 gate，才允许继续推进。
```

### 独立 AI 会话审查

配置：

```yaml
review:
  implementation:
    mode: separate-session
```

实际流程：

```text
1. 第一个 AI 完成实现工作。
2. 你开启另一个 AI 会话，让它只做审查。
3. 第二个 AI 在 review 文件里写入 reviewer、decision、blocking_issues 等信息。
4. 运行 agentflow gate review FEATURE-XXX。
5. 如果 blocking_issues 不是 0，或者 decision 不是 approved，gate 会失败。
```

审查文件需要包含类似信息：

```yaml
review_mode: separate-session
reviewer: external
decision: approved
blocking_issues: 0
reviewed_at: 2026-05-27
```
