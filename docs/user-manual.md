# Lang AgentFlow Kit 使用说明手册

这份手册只讲“搭好以后怎么用”。默认目标是：前期把配置和规则准备好，后期让 Manager Agent 自动执行流程检查，人只监督输出是否可信。

## 日常只需要一句话

新窗口或第二天继续开发时，优先这样说：

```text
你是 Manager，请继续开发。
```

建议把下面这条固定规则写进 `AGENTS.md`、`CLAUDE.md`、`.cursorrules` 或你的 AI 工具必读文件：

```text
当用户说“你是 Manager，请继续开发”时，先读取 AGENTS.md、agentflow.config.yml 和 project-docs/ACTIVE_WORK.md，再按当前状态继续。
```

Manager 应该自己完成：

```text
读取 AGENTS.md
-> 读取 agentflow.config.yml
-> 读取 ACTIVE_WORK
-> 确认当前 feature/task/stage
-> 运行必要 status/context/gate/check
-> 继续当前任务
-> 更新 ACTIVE_WORK
-> 按 heartbeat_mode 输出心跳
```

人不需要每天重新解释项目背景，也不需要手动输入一串难记命令。

## 配置也可以交给 AI

中大型项目开始前，`agentflow.config.yml` 值得认真配置，但不要求用户手动逐项填写。配置文件里的中文注释就是给人和 AI 一起看的：AI 可以根据这些注释判断哪些字段能改、什么时候改、改完需要跑哪些检查。

更推荐的方式是：让 AI 先给建议，用户确认后再改。不要让 AI 一上来就直接改 YAML。

推荐 prompt：

```text
你是 Manager。请读取 AGENTS.md、agentflow.config.yml 和需求文档。

先不要创建 feature，也不要写代码。

请根据项目情况检查并建议修改 agentflow.config.yml：
1. implementation.target_sides 应该包含 backend/frontend/mobile 哪些端？
2. workflow.default_type 应该是 standard、major 还是 sensitive？
3. review.mode 是否需要 human 或 separate-session？
4. hooks 是否应该自动运行 status、context、gate、test、board render？
5. manager.heartbeat_phrase 是否保持默认？
6. external_module_policy 是否适合当前项目？

请先输出建议和原因，等我确认后再修改 YAML。
```

确认后再让 AI 修改：

```text
按我确认的方案修改 agentflow.config.yml。
修改后运行可用检查，并更新 project-docs/ACTIVE_WORK.md。
```

AI 修改配置后，至少应该说明三件事：

- 改了哪些字段。
- 为什么这些字段适合当前项目。
- 已经运行了哪些检查，结果是什么。

## 备用命令

```sh
agentflow feature create "功能名称"
agentflow feature status FEATURE-XXX
agentflow feature next FEATURE-XXX
agentflow board render
```

它们分别表示：

| 命令 | 用途 |
| --- | --- |
| `feature create` | 创建一个功能工作包 |
| `feature status` | 看当前功能做到哪一步、卡在哪里 |
| `feature next` | 尝试推进下一步 |
| `board render` | 重新生成任务板 |

这些命令主要给 Manager 或 hook 使用。人只有在流程不对劲、Manager 输出缺少检查结果、或需要排查问题时才需要手动运行。

## Active Work 是什么

`project-docs/ACTIVE_WORK.md` 是跨会话恢复入口。它记录：

- 当前 feature
- 当前 stage
- 当前 task
- 当前 owner role
- backend/frontend/mobile/test/review 各自状态
- 上次执行了哪些检查
- 当前 blocker
- 下一步动作
- 是否需要人决策

它的目标是让你随时关闭窗口、随时重新打开，并用一句话恢复工作。

Manager 每轮结束都应该更新这个文件。

## 心跳口令是什么

心跳口令是 Manager 的守则校验。它不是功能结果，而是一个固定尾部，用来证明 Manager 还记得当前规则和状态。

默认口令是：

```text
AI为你保驾护航
```

你可以在 `agentflow.config.yml` 中修改：

```yaml
manager:
  resume_prompt: "你是 Manager，请继续开发。"
  heartbeat_phrase: "AI为你保驾护航"
  heartbeat_mode: compact
```

默认 `heartbeat_mode: compact`，每轮结束只输出一行：

```text
AI为你保驾护航 | checks: yes | active_work: yes | next: continue T004 | human: no
```

如果你把 `heartbeat_mode` 改成 `full`，Manager 才输出完整结构：

```yaml
heartbeat_phrase: AI为你保驾护航
anchor_pulse:
  current_feature: FEATURE-XXX or none
  current_stage: stage or none
  current_task: task id or none
  checks_run: yes/no
  active_work_updated: yes/no
  next_action_clear: yes/no
  human_needed: yes/no
```

人的监管点很简单：

- 如果口令存在，并且 `checks`、`active_work` 都是 `yes`，通常可以继续让 Manager 工作。
- 如果口令消失、`active_work` 不是 `yes`，或者连续几轮没有更新 `ACTIVE_WORK.md`，说明 Manager 可能开始漂移。
- 这时让它重新读取 `AGENTS.md` 和 `ACTIVE_WORK.md`，不要继续惯性开发。

介入提示：

```text
你漏掉了心跳口令。请重新读取 AGENTS.md、agentflow.config.yml 和 project-docs/ACTIVE_WORK.md，确认当前 feature/task/stage 后继续。
```

## 最简单的使用流程

完整流程可以先理解成 5 步：

```text
1. 放入需求文档或图片
2. 让 AI 拆 feature
3. 确认 feature 列表
4. 一次推进一个 feature
5. 用 status/next 看状态和推进
```

Feature 可以理解成一个“功能级小项目”，例如：

- 用户登录
- 商品管理
- 订单结算
- 移动端个人中心
- 后台权限管理

每个 feature 里面会保存自己的需求、计划、任务、实现记录、测试、审查和归档。

## 给 AI 的最短 Prompt

如果你已经有需求文档，可以直接对 AI 说：

```text
当前仓库已经初始化了 Lang AgentFlow Kit。

请先不要写代码。请阅读：
- AGENTS.md
- agentflow.config.yml
- 需求文档：<填写路径>
- 需求图片：<如有，填写路径>

请先帮我做三件事：
1. 把需求拆成 feature 列表。
2. 按依赖顺序排序。
3. 给每个 feature 建议类型：trivial / bug / standard / major / sensitive。

请输出 feature 表让我确认，不要创建 feature，也不要写代码。
```

确认后，再说：

```text
按我确认的 feature 表创建 feature bundle。
每个 feature 使用建议的 --type。
创建后运行 agentflow board render。
最后列出 feature ID、名称、类型和依赖顺序。
```

然后每次只推进一个 feature：

```text
现在处理 FEATURE-001-xxx。

请按 AgentFlow 流程推进：
1. 先读取 project-docs/ACTIVE_WORK.md。
2. 运行必要的 status/context/gate/check。
3. 根据 blocker 判断下一步。
4. 需要补文档就补 spec/plan/tasks。
5. 可以实现时再写代码。
6. 每次结束前更新 ACTIVE_WORK.md，并按 heartbeat_mode 输出心跳。

不要同时开始下一个 feature。
```

## Feature 类型怎么选

类型是 feature 级别的流程强度，不是每个 task 都要选。完整项目可能有数百个 task，但通常只需要确认几十个 feature 的类型。

| 类型 | 什么时候用 |
| --- | --- |
| `trivial` | 文案、样式、配置等极小改动 |
| `bug` | 修复已知 bug |
| `standard` | 普通业务功能，默认选择 |
| `major` | 跨多端、多模块、影响范围大的复杂功能 |
| `sensitive` | 用户、权限、认证、支付、上传、加密、租户隔离、外部模块复用等高风险功能 |

如果不确定，就先用 `standard`。涉及安全、权限、支付、用户数据时用 `sensitive`。

手动创建示例：

```sh
agentflow feature create "user auth" --type sensitive
agentflow feature create "product catalog" --type standard
agentflow feature create "fix login error" --type bug
agentflow board render
```

## 完整项目怎么拆

不要让人逐个定义数百个 task。推荐拆解层级是：

```text
项目需求
-> 模块/里程碑
-> feature
-> feature 内部 tasks
```

人只确认 feature 表，AI 再为每个 feature 生成内部 tasks。

可以让 AI 输出这张表：

```text
请根据完整需求文档做三层拆解：
1. 模块/里程碑
2. feature
3. feature 内部 tasks 草案

只在 feature 级别建议类型。

请输出 feature 拆分表：
- 序号
- feature 名称
- 所属模块
- 类型建议
- 选择原因
- 涉及端：backend / frontend / mobile
- 依赖 feature
- 风险
- 预估任务数
- 优先级

先不要创建 feature，等我确认。
```

## 有需求图片怎么办

把图片当作需求来源，但不要直接让 AI “照图开发”。先让 AI 把图片转成结构化需求。

推荐 prompt：

```text
请逐张分析需求图片，提取：
- 页面名称
- 页面目标
- 用户角色
- 主要区域
- 字段列表
- 操作按钮
- 交互流程
- 加载态、空状态、错误态、权限态
- 后端 API 需求
- 移动端适配要求
- 不明确的问题

请把图片信息和文字需求合并。
如果图片和文字需求冲突，以文字需求为主，并列出冲突点让我确认。
不要把看不清的字段或按钮自行脑补。
```

## 开发一个 Feature

当 feature 已创建后，日常只围绕一个 feature 工作。

推荐让 Manager 自己按状态推进：

```text
请处理 FEATURE-001-user-auth。

先读取 project-docs/ACTIVE_WORK.md。
然后运行必要的 agentflow feature status/context/gate/check。
如果当前还在 spec/plan/tasks 阶段，请先补齐文档，不要写代码。
如果已经可以实现，请只实现 tasks.md 中当前未完成的任务。
实现后运行测试或最接近的验证命令。
最后更新 feature 结果文件和 ACTIVE_WORK.md，并按 heartbeat_mode 输出心跳。
```

## 状态检查命令

这些命令是备用工具，优先由 Manager 或 hook 执行：

```sh
agentflow feature status FEATURE-XXX
agentflow feature next FEATURE-XXX
agentflow board render --check
```

需要更细检查时再用：

```sh
agentflow check FEATURE-XXX
agentflow gate spec FEATURE-XXX
agentflow gate plan FEATURE-XXX
agentflow gate tasks FEATURE-XXX
agentflow feature context FEATURE-XXX
```

用途：

| 命令 | 用途 |
| --- | --- |
| `check` | 检查文件结构、缺失文件和占位符 |
| `gate` | 只判断某阶段能不能过，不推进状态 |
| `context` | 生成给 AI 接手用的当前上下文 |

更完整的命令和触发场景见：

- [配置快速指南](./config-guide.md)
- [配置字段参考](./config-schema.md)
- [README 常用命令](../README.md)

## 前后端移动端项目

默认配置会按三端管理结果：

```yaml
implementation:
  target_sides:
    - backend
    - frontend
    - mobile
```

如果项目只有后端，可以改成：

```yaml
implementation:
  target_sides:
    - backend
```

这样新 feature 就不会要求 frontend/mobile 结果文件。

## 高级：第三方完整模块

第三方完整模块包括用户管理、权限/RBAC、支付、文件上传、后台模板等。不要默认直接复制公共模块，尤其是用户、权限、支付、上传、加密、租户隔离相关模块。

建议先登记模块：

```sh
agentflow module add public-user-management \
  --name "Public User Management Module" \
  --source-type public \
  --source github:example/user-management \
  --module-type module \
  --domain user \
  --risk critical \
  --mode reference-only
```

生成模块合同：

```sh
agentflow module contract public-user-management
```

创建使用该模块的 feature：

```sh
agentflow feature create "integrate user management module" --type sensitive
```

做复用分析：

```sh
agentflow reuse analyze FEATURE-XXX-integrate-user-management-module
agentflow reuse gate FEATURE-XXX-integrate-user-management-module
```

给 AI 的提示：

```text
这个 feature 涉及第三方用户管理模块。

请不要直接复制第三方代码。
先阅读模块 contract、security-notes 和 integration-notes。
分析 reference-only / vendor / direct-copy 的风险。
reuse gate 通过前不要实现。
```

推荐策略：

- 公共模块默认 `reference-only`。
- 用户、权限、认证、支付、上传、加密、租户隔离不要直接复制。
- 可以参考页面结构、API 设计和角色模型。
- 安全关键路径应在本项目中重新实现并审查。

## 高级：测试、审查和归档

实现完成后，至少留下测试记录和归档记录：

```text
features/FEATURE-XXX/implementation/test.md
features/FEATURE-XXX/archive.md
```

需要更严格时再补：

```text
features/FEATURE-XXX/implementation/review.md
features/FEATURE-XXX/results/backend.md
features/FEATURE-XXX/results/frontend.md
features/FEATURE-XXX/results/mobile.md
```

常用检查：

```sh
agentflow gate implement FEATURE-XXX
agentflow gate test FEATURE-XXX
agentflow gate review FEATURE-XXX
agentflow gate archive FEATURE-XXX
```

如果启用了人工批准：

```sh
agentflow approve FEATURE-XXX --stage spec
agentflow approve FEATURE-XXX --stage plan
```

## 推荐总控 Prompt

每次开始工作时，可以直接发：

```text
你是这个项目的 AgentFlow Manager。

规则：
- 先读取 AGENTS.md 和 project-docs/ACTIVE_WORK.md。
- 根据 ACTIVE_WORK 确认当前 feature、stage、task 和 blocker。
- 自行运行必要的 agentflow feature status/context/gate/check。
- 不直接编辑 project-docs/03_TASK_BOARD.md。
- 每次只推进一个 feature。
- 没有通过 spec/plan/tasks 前不要写代码。
- 实现时只做 tasks.md 中当前未完成的任务。
- 如果涉及第三方完整模块，先登记 module 并通过 reuse gate。
- 每次结束前更新 project-docs/ACTIVE_WORK.md。
- 最终回复必须包含配置中的心跳输出。
```

最重要的原则：

```text
先拆解，不写代码。
每次只推进一个 feature。
不确定时先看 ACTIVE_WORK 和 status。
高风险第三方模块先治理再实现。
人监管 Manager 输出，不替 Manager 手动搬运流程。
```
