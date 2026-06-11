# Lang AgentFlow Kit 使用说明手册

这份手册只讲“搭好以后怎么用”。默认路径尽量简单：把复杂的 gate、review、第三方模块治理放到后面的高级章节。

## 先记住 4 个命令

日常使用先记这几个就够了：

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

不确定当前该做什么时，先运行：

```sh
agentflow feature status FEATURE-XXX
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
1. 先运行 agentflow feature status FEATURE-001-xxx。
2. 根据 status 的 blocker 判断下一步。
3. 需要补文档就补 spec/plan/tasks。
4. 可以实现时再写代码。
5. 每次结束前运行可用验证命令，并汇报已完成内容、blockers 和下一步。

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

先看状态：

```sh
agentflow feature status FEATURE-001-user-auth
```

再让 AI 按状态推进：

```text
请处理 FEATURE-001-user-auth。

先运行：
agentflow feature status FEATURE-001-user-auth

如果当前还在 spec/plan/tasks 阶段，请先补齐文档，不要写代码。
如果已经可以实现，请只实现 tasks.md 中当前未完成的任务。
实现后运行测试或最接近的验证命令。
最后更新 feature 结果文件，并汇报状态。
```

推进下一步：

```sh
agentflow feature next FEATURE-001-user-auth
```

## 状态检查命令

简单模式只需要：

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
- 先运行 agentflow feature status，确认当前 feature、stage 和 blocker。
- 不直接编辑 project-docs/03_TASK_BOARD.md。
- 每次只推进一个 feature。
- 没有通过 spec/plan/tasks 前不要写代码。
- 实现时只做 tasks.md 中当前未完成的任务。
- 如果涉及第三方完整模块，先登记 module 并通过 reuse gate。
- 每次结束前运行可用验证命令，并汇报已改文件、验证结果、blockers 和下一步。
```

最重要的原则：

```text
先拆解，不写代码。
每次只推进一个 feature。
不确定时先看 status。
高风险第三方模块先治理再实现。
```
