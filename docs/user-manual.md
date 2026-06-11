# Lang AgentFlow Kit 使用说明手册

本文面向已经初始化好 AgentFlow 的项目使用者，说明拿到需求文档、需求图片或第三方模块后，如何从项目澄清、feature 拆分、逐步开发、状态检查到归档。

## 一、初始化后先做什么

初始化完成后，项目通常已经有这些文件：

```text
AGENTS.md
agentflow.config.yml
.agentflow/
project-docs/
features/
```

正式开发前，不要急着写代码。先让 AI 读取项目规则和需求来源，把项目级方向整理清楚。

推荐对 AI 说：

```text
当前仓库已经初始化了 Lang AgentFlow Kit。

请先不要写代码。先阅读：
- AGENTS.md
- agentflow.config.yml
- project-docs/00_PROJECT_CONTEXT.md
- project-docs/01_ARCHITECTURE.md
- project-docs/02_API_SPEC.md
- 需求文档：<填写路径>
- 需求图片：<填写图片路径列表，如没有可省略>

目标：
1. 将需求整理成项目级理解，更新 project-docs/00_PROJECT_CONTEXT.md。
2. 梳理前端、后端、移动端的架构边界，更新 project-docs/01_ARCHITECTURE.md。
3. 梳理核心 API、数据模型和端到端流程，更新 project-docs/02_API_SPEC.md。
4. 把需求拆成 feature 列表，按依赖顺序排序。
5. 每个 feature 给出名称、目标、范围、涉及端、依赖、风险和建议类型。
6. 先不要创建 feature，也不要写实现代码。完成后给我确认。
```

如果有需求图片，要求 AI 先把图片转成结构化需求：

```text
请逐张分析需求图片，提取：
- 页面名称
- 页面目标
- 入口路径
- 用户角色
- 主要区域
- 字段列表
- 操作按钮
- 交互流程
- 加载态、空状态、错误态、权限态
- 后端 API 需求
- 移动端适配要求
- 图片中不明确的问题

图片信息要和文字需求合并。如果图片和文字需求冲突，以文字需求为主，并列出冲突点让我确认。
不要把看不清的字段或按钮自行脑补，统一列为待确认问题。
```

## 二、拆分 Feature

项目级文档确认后，再创建 feature。Feature 是一个可独立推进的功能单元，不是 Git 分支。

示例：

```sh
agentflow feature create "user auth" --type sensitive
agentflow feature create "product catalog" --type standard
agentflow feature create "order checkout" --type sensitive
agentflow feature create "mobile profile page" --type standard
agentflow board render
```

常见 feature 类型：

| 类型 | 适合场景 |
| --- | --- |
| `trivial` | 文案、小样式、小配置 |
| `bug` | 缺陷修复 |
| `standard` | 普通功能 |
| `major` | 多端、多模块或高复杂度功能 |
| `sensitive` | 用户、权限、支付、文件上传、加密、租户隔离等高风险功能 |

创建后用下面命令确认状态：

```sh
agentflow feature status FEATURE-001-user-auth
agentflow board render --check
```

不要直接编辑 `project-docs/03_TASK_BOARD.md`。它是生成文件，状态来源是每个 feature 的 `state.yml`。

## 三、单个 Feature 的标准推进方式

每次只推进一个 feature。不要让 AI 一次性同时开发多个 feature。

推荐对 AI 说：

```text
现在开始处理 FEATURE-001-user-auth。

请先运行：
agentflow feature status FEATURE-001-user-auth

如果 active context 不存在，请运行：
agentflow feature context FEATURE-001-user-auth

然后阅读：
- .agentflow/state/active_context.md
- features/FEATURE-001-user-auth/spec.md
- features/FEATURE-001-user-auth/plan.md
- features/FEATURE-001-user-auth/tasks.md
- 相关 project-docs

当前阶段只补齐 spec、plan、tasks，不写代码。
完成后运行对应 gate 检查。如果 gate 不通过，按 blocker 修正文档直到通过。
```

常用状态命令：

```sh
agentflow feature status FEATURE-001-user-auth
agentflow feature context FEATURE-001-user-auth
agentflow check FEATURE-001-user-auth
agentflow gate spec FEATURE-001-user-auth
agentflow gate plan FEATURE-001-user-auth
agentflow gate tasks FEATURE-001-user-auth
agentflow feature next FEATURE-001-user-auth
```

这些命令的用途：

| 命令 | 用途 |
| --- | --- |
| `feature status` | 查看当前 stage、next gate、进度和 blockers |
| `feature context` | 生成当前 feature 的工作上下文 |
| `check` | 检查 bundle 结构、缺失文件和占位符 |
| `gate` | 判断某阶段是否可以通过，不修改状态 |
| `feature next` | 尝试推进到下一阶段 |
| `board render --check` | 检查任务板是否最新 |

## 四、进入开发阶段

当 spec、plan、tasks 通过后，再开始写代码。

推荐对 AI 说：

```text
现在开始实现 FEATURE-001-user-auth。

规则：
1. 先运行 agentflow feature status FEATURE-001-user-auth。
2. 读取 active_context.md、spec.md、plan.md、tasks.md。
3. 只实现 tasks.md 中当前未完成的任务。
4. 按 backend/frontend/mobile 分别记录结果到 results/backend.md、results/frontend.md、results/mobile.md。
5. 每完成一个任务，更新 tasks.md。
6. 跑测试或最接近的验证命令。
7. 更新 implementation/test.md。
8. 运行 agentflow feature status 或 gate。
9. 不要跳过 review、fix、archive。
10. 完成到 test gate 后停下来汇报，不要自动开始下一个 feature。
```

如果当前项目只有后端或只有前端，应先调整 `agentflow.config.yml`：

```yaml
implementation:
  target_sides:
    - backend
```

这样新 feature 不会生成或要求无关的 `frontend`、`mobile` result 文件。

## 五、测试、审查和归档

实现完成后，至少要留下测试和审查记录：

```text
features/FEATURE-001-user-auth/implementation/test.md
features/FEATURE-001-user-auth/implementation/review.md
features/FEATURE-001-user-auth/archive.md
```

常用命令：

```sh
agentflow gate implement FEATURE-001-user-auth
agentflow gate test FEATURE-001-user-auth
agentflow gate review FEATURE-001-user-auth
agentflow gate archive FEATURE-001-user-auth
agentflow feature next FEATURE-001-user-auth
```

如果项目启用了人工批准或独立审查，可能需要：

```sh
agentflow approve FEATURE-001-user-auth --stage spec
agentflow approve FEATURE-001-user-auth --stage plan
```

归档前确认：

- spec、plan、tasks 已通过。
- backend/frontend/mobile 结果已记录。
- 测试结果不是 pending 或 not tested。
- review 有明确 decision，且无 blocking issues。
- archive 记录了最终结果、变更摘要、测试摘要、风险和遗留问题。

## 六、引入第三方完整模块

第三方完整模块指外部已有的一整套功能，例如：

- 用户管理
- 权限/RBAC
- 管理后台模板
- 支付模块
- 文件上传模块
- 组织/租户管理

这类模块不要直接复制进项目，尤其是用户、权限、支付、上传、加密、租户隔离等敏感领域。推荐先做登记和准入治理。

### 1. 登记模块

以公共用户管理模块为例：

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

查看模块：

```sh
agentflow module list
agentflow module show public-user-management
```

生成本地合同和 notes：

```sh
agentflow module contract public-user-management
```

这会生成类似文件：

```text
.agentflow/modules/public-user-management/module-contract.yml
.agentflow/modules/public-user-management/security-notes.md
.agentflow/modules/public-user-management/integration-notes.md
```

### 2. 为使用该模块创建 Feature

例如：

```sh
agentflow feature create "integrate user management module" --type sensitive
```

然后让 AI 先做复用分析：

```text
现在处理 FEATURE-XXX-integrate-user-management-module。

请不要复制第三方代码。先阅读：
- .agentflow/modules/public-user-management/module-contract.yml
- .agentflow/modules/public-user-management/security-notes.md
- .agentflow/modules/public-user-management/integration-notes.md
- features/FEATURE-XXX-integrate-user-management-module/spec.md

目标：
1. 明确该模块只作为 reference-only、vendor 还是 direct-copy。
2. 对用户、权限、认证、租户隔离、数据安全做风险分析。
3. 更新 reuse-analysis.md 和 external-module-risk.md。
4. 运行 reuse gate。
5. gate 通过前不要实现。
```

执行命令：

```sh
agentflow reuse analyze FEATURE-XXX-integrate-user-management-module
agentflow reuse gate FEATURE-XXX-integrate-user-management-module
```

### 3. 复用模式建议

| 模式 | 说明 | 建议 |
| --- | --- | --- |
| `reference-only` | 只参考设计、接口或交互，不复制代码 | 公共模块默认推荐 |
| `vendor` | 将外部模块作为供应商代码纳入项目 | 需要人工批准和安全审查 |
| `direct-copy` | 直接复制公共代码 | 默认不建议，公共高风险模块应阻止 |

对用户管理这类模块，通常建议：

- 可以参考页面结构、角色模型、API 设计。
- 不直接复制认证、权限、密码、token、租户隔离相关代码。
- 重新实现安全关键路径。
- 明确 license、来源、维护责任和安全边界。
- 对数据模型、权限模型和审计字段做本地化设计。

## 七、日常工作节奏

每天开始：

```sh
agentflow check --all
agentflow board render --check
agentflow feature status FEATURE-XXX
agentflow feature context FEATURE-XXX
```

编码前：

```sh
agentflow gate spec FEATURE-XXX
agentflow gate plan FEATURE-XXX
agentflow gate tasks FEATURE-XXX
```

编码后：

```sh
npm test
agentflow gate implement FEATURE-XXX
agentflow feature status FEATURE-XXX
```

收尾前：

```sh
agentflow gate test FEATURE-XXX
agentflow gate review FEATURE-XXX
agentflow gate archive FEATURE-XXX
agentflow board render --check
```

如果不确定当前做什么，优先运行：

```sh
agentflow feature status FEATURE-XXX
```

把 CLI 输出当作当前 feature 状态的事实来源，不要只看聊天记录或任务板。

## 八、推荐总控 Prompt

可以把下面这段作为每次开始工作的固定提示：

```text
你是这个项目的 AgentFlow Manager。

工作规则：
- 先读 AGENTS.md 和 agentflow.config.yml。
- 任何编码前必须确认当前 feature、当前 stage 和 next gate。
- 以 agentflow feature status 的输出作为事实来源。
- 不直接编辑 project-docs/03_TASK_BOARD.md。
- 每次只推进一个 feature。
- 没有通过 spec/plan/tasks gate 前不要写代码。
- 实现时严格按 tasks.md 执行。
- 所有 backend/frontend/mobile/test/review 结果必须写回 feature bundle。
- 如果涉及第三方完整模块，必须先登记 module、生成 contract、执行 reuse analyze 和 reuse gate。
- 每次结束前运行可用验证命令，并汇报 blockers、已改文件、验证结果和下一步。
```

最重要的原则：

```text
先拆解，不写代码。
每次只推进一个 feature。
gate 不通过，不进入下一阶段。
第三方高风险模块不直接复制，先治理再实现。
```
