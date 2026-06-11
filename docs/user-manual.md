# Lang AgentFlow Kit 使用说明手册

这份手册只讲“搭好以后怎么用”。核心原则是：用户说目标，Manager 负责反问、执行命令、更新状态和输出心跳。用户不应该每天记一串 `agentflow` 指令。

## 最短用法

新窗口或第二天继续开发：

```text
你是 Manager，请继续开发。
```

项目刚开始，需要拆完整需求：

```text
帮我拆分这个项目，需求在 <文档路径>，图片在 <图片路径>。
```

当前阶段你确认完成了：

```text
当前阶段完成，继续下一阶段。
```

要加入第三方模块：

```text
帮我加入一个用户管理模块，地址是 <Git 地址或本地路径>。
```

这些短句背后的固定流程应该写进 `AGENTS.md`、`CLAUDE.md`、`.cursorrules` 或 `.agentflow/skills/agentflow-manager-workflow/SKILL.md`。用户不需要把流程复制给 AI。

需要用户确认的地方，也应该由 Manager 主动发起。比如 Manager 先给出“推荐选项 + 原因 + 影响”，用户只回答“选 A / 选 B / 同意 / 不同意”，而不是用户主动输入一整段配置或命令。

## Manager 应该自动做什么

Manager 每轮开始先读：

```text
AGENTS.md
agentflow.config.yml
.agentflow/skills/agentflow-manager-workflow/SKILL.md
project-docs/ACTIVE_WORK.md
```

然后自己完成：

```text
确认当前 feature / stage / task
-> 发现缺信息就反问用户
-> 运行必要的 status / context / gate / check
-> 能推进就推进，不能推进就说明 blocker
-> 更新 feature 记录和 ACTIVE_WORK.md
-> 按 heartbeat_mode 输出心跳
```

人的工作是确认方向、回答问题、看 Manager 汇报是否可信。不是手动搬运命令。

## 需要确认时怎么问

Manager 不应该把技术字段直接丢给用户。更好的问法是：

```text
这个项目看起来有 Web 前端和后端，没有移动端。
我建议配置为 backend + frontend，不生成 mobile 检查。
这样后续 feature 不会因为缺 mobile 结果被卡住。
是否按这个方案修改？
```

不好的问法是：

```text
请填写 implementation.target_sides。
```

所有需要确认的地方都按这个原则处理：

- 先解释人能理解的业务含义。
- 给出推荐选项。
- 用户确认后，Manager 再改 YAML、创建 feature、推进阶段或引入模块。

## 初始化配置怎么做

`agentflow.config.yml` 是用户定义项目规则的地方，但不要求用户懂每个字段。正确流程是 Manager 反问用户，再帮用户填写。

用户只需要说：

```text
帮我配置 AgentFlow。
```

Manager 应该问类似这些问题：

```text
1. 这个项目包含哪些端：后端、Web 前端、移动端？
2. 是否涉及登录、用户、权限、支付、文件上传、加密或多租户？
3. 是否会引入现成第三方模块？
4. 审查希望偏轻量，还是关键阶段需要人工确认？
5. 心跳口令是否使用默认的“AI为你保驾护航”？
```

用户回答后，Manager 再做：

```text
提出 YAML 修改建议
-> 等用户确认
-> 修改 agentflow.config.yml
-> 检查 YAML 和 AgentFlow 状态
-> 更新 ACTIVE_WORK.md
```

这比让用户复制一段很长的 prompt 更稳。配置是用户决策，AI 的职责是问清楚、解释影响、准确落地。

## Active Work 是什么

`project-docs/ACTIVE_WORK.md` 是跨会话恢复入口。它记录：

- 当前 feature
- 当前 stage
- 当前 task
- 当前 owner role
- backend / frontend / mobile / test / review 状态
- 上次执行了哪些检查
- 当前 blocker
- 下一步动作
- 是否需要人决策

它的目标是让用户随时关闭窗口、随时重新打开，再用一句话恢复工作。

## 心跳口令是什么

心跳口令是 Manager 的守则校验。默认口令是：

```text
AI为你保驾护航
```

默认 `heartbeat_mode: compact`，每轮结束只输出一行：

```text
AI为你保驾护航 | checks: yes | active_work: yes | next: continue T004 | human: no
```

如果口令消失、`active_work` 不是 `yes`，或者 Manager 连续几轮没有更新 `ACTIVE_WORK.md`，让它重新读取规则：

```text
你漏掉了心跳口令。请重新读取 AGENTS.md、agentflow.config.yml 和 project-docs/ACTIVE_WORK.md，确认当前状态后继续。
```

## 完整项目怎么拆

不要让用户逐个定义数百个 task。推荐层级是：

```text
项目需求
-> 模块/里程碑
-> feature
-> feature 内部 tasks
```

用户只需要给出需求来源：

```text
帮我拆分这个项目，需求文档在 docs/requirements.md。
```

Manager 应该自动做：

```text
读取需求
-> 有图片就先转成结构化需求
-> 推断项目画像和 YAML 配置建议
-> 识别可能要导入的第三方模块
-> 询问用户配置和模块决策是否符合预期
-> 拆模块和里程碑
-> 生成 feature 表
-> 给每个 feature 建议类型和原因
-> 标出依赖、风险、涉及端和预估任务数
-> 让用户确认
-> 确认后创建 feature bundle 并刷新任务板
```

用户只确认 feature 表，不需要写创建命令。

如果 feature 表里有不确定项，Manager 应该逐项反问，例如“这个功能是否必须支持移动端？”“这个模块是否涉及权限控制？”，而不是要求用户自己改表格。

需求导入后，Manager 应该自动做一次配置评估，不需要用户另外说“帮我配置 YAML”。例如需求里出现用户管理、权限、支付、上传、移动端等信息时，Manager 应主动提出：

```text
我从需求里推断：
- 项目端：backend + frontend
- 高风险领域：user + permission
- 建议 default_type: standard，但用户/权限相关 feature 用 sensitive
- 建议保留 review gate

是否按这个方向更新 agentflow.config.yml？
```

如果需求里出现“用户管理模块”“后台模板”“支付模块”等可复用模块，Manager 还应该主动问：

```text
需求里包含用户管理。你希望：
A. 本项目从零实现
B. 引入现成模块作为依赖
C. 只参考现成模块设计，本项目自己实现

如果要引入，请告诉我 Git 地址或本地路径。
```

用户选择引入后，Manager 必须重新调整 feature 表。比如“用户管理”不再拆成完整自研开发 feature，而是拆成“模块登记/风险评估/集成/适配/测试/审查”等 feature 或 tasks。

## 有需求图片怎么办

用户只需要说明图片在哪里：

```text
需求图片在 design/login.png 和 design/admin.png，请一起分析。
```

Manager 应该先把图片转成结构化需求：

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

如果图片和文字需求冲突，Manager 应列出冲突点让用户确认，不要自行脑补。

## Feature 类型怎么选

类型是 feature 级别的流程强度，不是每个 task 都要选。

| 类型 | 什么时候用 |
| --- | --- |
| `trivial` | 文案、样式、配置等极小改动 |
| `bug` | 修复已知 bug |
| `standard` | 普通业务功能，默认选择 |
| `major` | 跨多端、多模块、影响范围大的复杂功能 |
| `sensitive` | 用户、权限、认证、支付、上传、加密、租户隔离、外部模块复用等高风险功能 |

用户不需要自己记这些类型。Manager 在拆 feature 时应该自动建议类型，给出原因，并让用户确认。

## 开发一个 Feature

用户不需要说一大段流程。常用短句就够了：

```text
继续开发 FEATURE-001-user-auth。
```

或者：

```text
当前阶段完成，继续下一阶段。
```

Manager 应该自动做：

```text
读取 ACTIVE_WORK.md
-> 确认当前 feature/stage/task
-> 运行必要检查
-> 如果 gate 不通过，说明 blocker 并修复或询问
-> 如果可以推进，进入下一阶段
-> 实现时只处理当前 task
-> 运行测试或最接近的验证
-> 更新结果文件和 ACTIVE_WORK.md
-> 输出心跳
```

用户只有在 Manager 明确要求决策时再介入。

## 第三方完整模块

第三方完整模块包括用户管理、权限/RBAC、支付、文件上传、后台模板等。

用户可以直接说：

```text
帮我加入一个用户管理模块，Git 地址是 github:example/user-management。
```

如果用户没说清楚，Manager 应该反问：

```text
1. 这是公共模块、内部模块，还是第三方商业模块？
2. 你希望只参考设计，作为依赖使用，vendor 进项目，还是直接复制代码？
3. 它涉及哪些领域：用户、权限、支付、上传、加密、租户？
4. 是否允许人工审查后再进入实现？
```

Manager 后续自动执行：

```text
登记 module
-> 生成 module contract
-> 创建或更新集成 feature
-> 做 reuse analyze
-> 通过 reuse gate 后再实现
```

默认策略：

- 公共模块默认 `reference-only`。
- 用户、权限、认证、支付、上传、加密、租户隔离不要直接复制。
- 如果用户强制要求 vendor 或 direct-copy，Manager 必须先说明风险、要求确认，并保留审查记录。

如果第三方模块是在需求拆分之后才决定导入，Manager 应该回到 feature 表，重新评估受影响 feature，而不是继续按原来的自研计划开发。

## 测试、审查和归档是什么

这一块可以理解成“收尾证明”。它不是让用户手动操作的高级流程，而是 Manager 在 feature 做完后必须自动完成的交付检查。

- 测试：证明功能跑过，记录跑了什么、结果是什么。
- 审查：检查代码有没有明显 bug、风险、接口漂移或安全问题。
- 归档：把这个 feature 做了什么、改了哪些文件、还有什么风险写清楚。

正常情况下，用户不需要每次提醒。Manager 发现当前 feature 的实现任务完成后，应该自动进入收尾流程。

下面这句话只是兜底：如果你发现 Manager 没有自动收尾，直接提醒它：

```text
这个 feature 做完了，请收尾。
```

Manager 应该自动：

```text
确认当前 feature 的实现任务已完成
-> 检查是否还有 blocker
-> 调度 Test Agent 或新会话运行测试/验证
-> 写 test.md
-> 调度 Code Reviewer 或独立会话做审查
-> 写 review.md
-> 如果发现 blocker，调度 Fix Agent 修复，再重新测试和审查
-> 写 archive.md
-> 更新任务板和 ACTIVE_WORK.md
```

这些文件大致表示：

| 文件 | 作用 | 用户需要做什么 |
| --- | --- | --- |
| `implementation/test.md` | 记录跑了哪些测试、结果是否通过、还有什么没测 | 看 Manager 是否真的跑了可信检查 |
| `implementation/review.md` | 记录审查结论、阻塞问题、风险 | 如果有 blocker，等 Manager 修完再确认 |
| `archive.md` | 记录这个 feature 最终交付了什么、改了哪些文件、剩余风险 | 确认摘要是否符合预期 |

如果测试失败，Manager 不应该直接归档。它应该说明：

```text
测试失败在哪里
-> 准备怎么修
-> 修完后重新跑什么验证
```

如果审查发现 blocker，Manager 不应该让 feature 进入完成状态。它应该先修复，或者问用户是否接受风险。

如果项目配置要求人工批准，Manager 会主动提示用户确认，例如：

```text
这个 feature 的测试和审查已通过，归档摘要如下。
是否确认进入完成状态？
```

用户只需要回答“确认”或指出问题，不需要自己写 `test.md`、`review.md`、`archive.md`。

为了避免 Manager 上下文过大，Manager 不应该亲自吞下所有测试日志、审查细节和修复过程。推荐分工是：

| 角色 | 负责什么 |
| --- | --- |
| Manager | 判断是否进入收尾、分派角色、汇总结论、更新状态 |
| Test Agent | 运行测试或验证，写 `test.md` |
| Code Reviewer | 审查代码和风险，写 `review.md` |
| Fix Agent | 只修复测试或审查发现的问题 |
| Commit/Archive Agent | 整理 `archive.md` 和最终摘要 |

这样 Manager 保持轻量，只看结论、blocker 和下一步，不把长日志和实现细节长期留在主上下文里。

## 备用命令

这些命令主要给 Manager、hook 或排查问题时使用。普通用户不需要每天手动执行。

```sh
agentflow feature status FEATURE-XXX
agentflow feature next FEATURE-XXX
agentflow board render --check
agentflow check FEATURE-XXX
agentflow gate spec FEATURE-XXX
agentflow gate plan FEATURE-XXX
agentflow gate tasks FEATURE-XXX
agentflow feature context FEATURE-XXX
```

更完整的命令和触发场景见：

- [配置快速指南](./config-guide.md)
- [配置字段参考](./config-schema.md)
- [README 常用命令](../README.md)

## 推荐固化规则

把下面规则写进 `AGENTS.md`、`CLAUDE.md`、`.cursorrules` 或项目 Skill：

```text
用户说“继续开发”“当前阶段完成”“帮我拆项目”“加入模块”时，不要要求用户复制长 prompt。
你是 Manager，先读取 AGENTS.md、agentflow.config.yml、.agentflow/skills/agentflow-manager-workflow/SKILL.md 和 project-docs/ACTIVE_WORK.md。
缺信息就反问用户。
需要命令就自己运行。
需要改 YAML 就先给建议，等确认后再改。
每轮结束更新 ACTIVE_WORK.md，并输出配置中的心跳。
```
