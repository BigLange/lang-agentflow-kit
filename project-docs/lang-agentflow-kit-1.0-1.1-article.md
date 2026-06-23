# 从能守住流程，到能接住长期协作：Lang AgentFlow Kit 1.0.0 / 1.1.0 / 1.1.1 的三次迭代

前一篇文章里，我介绍了 Lang AgentFlow Kit 0.6.0 的一次重要变化。

如果说 0.6.0 的重点，是把它从“AI 协作流程脚手架”推进到“本地工程守卫器”，那么 1.0.0、1.1.0 和 1.1.1 的重点，就不再只是继续加 gate 或模板了。

这几次迭代开始处理另一个更现实的问题：

**当流程已经能被守住之后，怎么让它真正适合每天使用。**

也就是说，工具不只要能检查状态、阻止跳步、留下记录，还要让用户不用每天记一堆命令，不用反复解释上下文，不用把所有测试和验收都塞给 AI，也不用让所有 subagent 都用同一种模型规格去做不同难度的任务。

这三次版本的变化，可以概括成三条线：

- 1.0.0：把 Manager 工作流稳定下来，让用户用短句驱动长期项目。
- 1.1.0：把测试、人工验收、模型分级和 Codex adapter 接进工作流。
- 1.1.1：把项目架构决策提前到 feature 拆分之前，避免 AI 在方向未定时过早开工。

它们解决的不是“有没有流程”，而是“这个流程能不能长期跑下去”。

## 1.0.0：让 Manager 成为真正的恢复入口

在 0.6.0 之前，AgentFlow 已经有了 feature state、gate、任务板、doctor、reuse gate 等工程守卫能力。

但日常使用时还有一个问题：

用户还是容易被迫记命令。

比如：

```bash
agentflow feature status FEATURE-001-user-auth
agentflow feature context FEATURE-001-user-auth
agentflow gate plan FEATURE-001-user-auth
agentflow board render
```

这些命令对工具来说很重要，但不应该成为用户每天操作 AI 项目的主要方式。

真实使用里，用户更自然的表达应该是：

```text
你是 Manager，请继续开发。
```

或者：

```text
帮我拆分这个项目，需求在 docs/requirements.md。
```

所以 1.0.0 的核心，不是新增更多命令，而是把这些命令背后的固定流程沉到 Manager 工作流里。

## 一、ACTIVE_WORK 成为跨会话恢复点

1.0.0 新增了一个关键文件：

```text
project-docs/ACTIVE_WORK.md
```

它的作用很直接：记录当前项目到底进行到哪里。

里面会包含：

- 当前 feature；
- 当前 stage；
- 当前 task；
- 当前 owner role；
- 上次跑过哪些检查；
- 当前 blocker；
- 下一步动作；
- 是否需要人做决策。

这解决的是 AI 长期协作里很常见的问题：

**新开一个窗口之后，AI 不知道现在应该继续哪里。**

过去这个信息可能散落在聊天记录、任务板、feature 文件和用户脑子里。

现在新会话只需要先读：

```text
AGENTS.md
agentflow.config.yml
project-docs/ACTIVE_WORK.md
```

再结合当前 feature 状态，就能恢复工作。

这让“继续开发”从一句模糊指令，变成一个可执行的本地协议。

## 二、短句触发固定 Manager 流程

1.0.0 还把 Manager 日常工作流沉淀到了项目 skill 里：

```text
.agentflow/skills/agentflow-manager-workflow/
```

这意味着用户不需要每次复制长 prompt。

很多常见意图可以变成短句：

```text
帮我配置 AgentFlow。
帮我拆分这个项目，需求在 docs/requirements.md。
当前阶段完成，继续下一阶段。
这个 feature 做完了，请收尾。
```

Manager 应该自己完成：

```text
读取规则
-> 读取 ACTIVE_WORK
-> 运行必要 status / gate / context
-> 判断能不能推进
-> 缺信息就反问用户
-> 更新状态和任务板
-> 输出心跳
```

用户不需要知道每一步对应哪个 CLI 命令。

这背后的变化是：AgentFlow 开始把“命令行工具”进一步包装成“AI Manager 的工作协议”。

CLI 仍然存在，但它更多是 Manager、hook、CI 或排查问题时使用。

## 三、配置不再要求用户懂 YAML 字段

1.0.0 还加强了 `agentflow.config.yml` 的 AI 说明。

例如，配置里会明确告诉 Manager：

- 创建 feature 前先读配置；
- 没有移动端就删除 `implementation.target_sides` 里的 `mobile`；
- 涉及 auth、user、permission、payment 等敏感领域时使用 `sensitive`；
- AI 修改 YAML 前，必须先解释为什么改、改哪些字段、改完影响什么；
- 用户确认后再修改配置；
- 修改后要验证 YAML，并运行必要检查。

这件事看起来像是文档优化，但实际很重要。

因为很多用户并不想知道：

```yaml
implementation:
  target_sides:
    - backend
    - frontend
```

他们只关心：

```text
这个项目有没有移动端？
后续流程会不会因为 mobile 文件缺失而卡住？
```

所以 Manager 应该用人能理解的话提出建议：

```text
这个项目看起来只有 Web 前端和后端，没有移动端。
我建议从 target_sides 里移除 mobile。
这样后续 feature 不会因为缺 mobile 结果文件被 gate 阻塞。
是否按这个方案修改？
```

这让配置从“用户手写 YAML”，变成“AI 解释影响，用户确认决策”。

## 四、需求导入时先判断项目画像

1.0.0 还补上了一个很关键的流程：导入需求后，Manager 不应该马上创建 feature。

它应该先判断项目画像：

- 这个项目有哪些端？
- 是否涉及用户、权限、支付、上传、加密、多租户？
- 是否可能引入第三方模块？
- 哪些 feature 应该是 standard？
- 哪些 feature 应该是 sensitive？
- 是否需要调整 AgentFlow 配置？

比如需求里出现“用户管理”“权限系统”“支付退款”，Manager 就应该主动提出：

```text
我从需求里推断：
- 项目涉及 backend + frontend
- 高风险领域包括 user、permission、payment
- 普通功能可以用 standard
- 用户/权限/支付相关 feature 建议使用 sensitive
- 建议保留 review gate

是否按这个方向更新 agentflow.config.yml？
```

这一步的价值在于，它避免了 AI 过早进入“拆任务”和“写代码”。

先判断项目画像，再拆 feature，流程会更稳。

## 1.0.0 的关键词：Manager 稳定化

所以 1.0.0 的关键词不是“更多功能”，而是：

- 恢复入口；
- 短句驱动；
- Manager 自动跑命令；
- 配置确认协议；
- 心跳机制；
- 需求导入后的项目画像判断。

它把 0.6.0 的 runtime guardrails，进一步变成了日常可用的 Manager workflow。

如果说 0.6.0 解决的是：

> 工具能不能守住流程？

那么 1.0.0 解决的是：

> 用户能不能用一句话继续这个流程？

## 1.1.0：让测试、验收和模型分级进入流程

1.1.0 继续往前走了一步。

当 Manager workflow 稳定以后，又会出现几个新的现实问题。

### 第一个问题：AI 测试和人工测试不能混在一起

AI 很适合做这些测试：

- 单元测试；
- 接口测试；
- 构建检查；
- lint / typecheck；
- 一部分集成测试；
- 可自动化的回归验证。

这些测试应该跟着 feature 同步执行。

因为 AI 执行成本低，速度快，而且可以在刚实现完时立刻验证，思路不会断。

但还有另一类测试，AI 并不适合全部承担：

- 网页真实交互；
- App 真机体验；
- UI 是否遮挡；
- 多步骤业务流程是否顺手；
- 视觉、滚动、toast、弹窗、输入体验；
- 需要 QA 或产品最终确认的场景。

这些测试如果强行让 AI 用浏览器自动化去跑，成本高、token 消耗大，稳定性也不一定好。

所以 1.1.0 把测试拆成两条线。

## 一、AI 测试变成强制同步资产

每个 feature 会新增：

```text
test-cases.md
test-results.md
manual-acceptance.md
```

其中：

- `test-cases.md`：AI / 自动化测试用例；
- `test-results.md`：AI / 自动化测试执行结果；
- `manual-acceptance.md`：feature 本地的人工验收摘要或引用。

只要 feature 进入 test 阶段，AI 测试用例和结果就不能只是口头说“测过了”。

它必须落到文件里。

例如：

```text
TC-AI-001: 创建任务成功
TC-AI-002: 标题为空时返回错误
TC-AI-003: 状态更新后更新时间变化
```

测试结果也要记录：

```text
Passed: 3
Failed: 0
Skipped: 0
```

这让 AI 测试从“聊天里的承诺”，变成“feature bundle 里的交付资产”。

## 二、人工验收集中到项目级清单

另一方面，人工验收不适合分散在每个 feature 里让人一个个找。

所以 1.1.0 新增了项目级人工验收总表：

```text
project-docs/04_MANUAL_ACCEPTANCE.md
```

它用于集中记录：

- 浏览器验收；
- App 验收；
- 真机测试；
- QA 反馈；
- 产品确认；
- 截图、缺陷链接、禅道 bug 链接等证据。

这样 feature 可以先完成 AI 可验证的部分：

```text
implementation_done: yes
ai_verified: yes
manual_acceptance: pending
```

人工验收可以等到大模块、里程碑或项目整体完成后集中处理。

这更接近真实团队的节奏。

AI 测试负责快节奏闭环。

人工验收负责低频但真实的体验确认。

两者不应该混在同一个 gate 里。

## 三、模型路由：不同任务不应该都用同一种 AI

另一个问题来自 subagent 分派。

在一个 feature 里，不同任务的难度和风险差别很大。

比如：

- 修改文案；
- 写接口；
- 做权限校验；
- 设计支付退款；
- 审查安全风险；
- 整理 archive。

如果这些任务都用同一个模型规格，要么浪费成本，要么风险不够。

所以 1.1.0 新增了：

```text
model-routing.md
```

它用中性的 reasoning 档位描述任务需要多少推理强度：

```text
low
medium
high
extra-high
```

默认规则大致是：

| Feature 类型 | 默认档位 |
| --- | --- |
| trivial | low |
| bug | medium |
| standard | medium |
| major | high |
| sensitive | extra-high |

任务也可以覆盖默认档位。

例如：

```text
T002 Backend Implementer -> medium / high / extra-high，取决于 feature 风险
T006 Code Reviewer -> high
T008 Commit Agent -> low
```

这背后的设计不是绑定某个具体模型。

AgentFlow 不应该写死：

```text
某个任务必须用某某模型名
```

因为 Codex、Claude Code、Gemini CLI 或其他工具的模型选择方式都不一样。

更稳的方式是，AgentFlow 只表达：

```text
这个任务需要 low / medium / high / extra-high 级别的推理强度
```

具体怎么映射给某个工具，由 adapter 负责。

## 四、前置阶段也纳入模型分级

模型路由不只覆盖实现阶段。

1.1.0 里，`model-routing.md` 同时包含两类路由：

```text
Stage Routing
Dispatch Task Routing
```

Stage Routing 覆盖：

- spec；
- spec-review；
- plan；
- plan-review；
- tasks；
- task-review。

这意味着写 spec、写 plan、拆 tasks 也可以按风险分级。

例如：

| 阶段 | 普通 feature | sensitive feature |
| --- | --- | --- |
| spec | medium | extra-high |
| plan | medium | extra-high |
| tasks | medium | extra-high |
| review | high | high / extra-high |

这很重要。

因为很多风险不是在写代码时才产生的，而是在 spec 和 plan 阶段就已经埋下了。

权限、支付、租户隔离、文件上传这类功能，如果一开始 spec 没写清，后面实现再强也很难补回来。

## 五、Codex adapter：先生成计划，再决定是否执行

1.1.0 还加入了一个初步的 Codex adapter。

它支持两个层次。

前置阶段：

```bash
agentflow stage plan FEATURE-001-user-auth --stage spec --adapter codex
agentflow stage run FEATURE-001-user-auth --stage spec --adapter codex
```

实现分派阶段：

```bash
agentflow dispatch plan FEATURE-001-user-auth --adapter codex
agentflow dispatch run FEATURE-001-user-auth --adapter codex
```

这里有一个刻意保守的设计：

默认不直接执行。

`plan` 会生成：

- 每个 subagent 的 prompt；
- 一个 plan.md；
- 一个 run script。

`run` 默认也只是 dry-run，提示脚本路径。

只有显式加上：

```bash
--execute
```

才会真正调用：

```bash
codex exec
```

并把：

```text
low / medium / high / extra-high
```

映射成 Codex 的：

```text
model_reasoning_effort
```

例如：

```bash
codex exec -c model_reasoning_effort="extra-high"
```

这一步还不是完整的多 agent 平台。

但它已经把“Manager 判断任务等级”和“实际启动不同规格的 Codex 子任务”之间，打通了一条明确路径。

## 六、Active Context 变得更克制

随着测试资产、模型路由、人工验收、adapter 文件增加，另一个问题也出现了：

如果 Manager 每轮都读所有文件，上下文会越来越长。

所以 1.1.0 对 `agentflow feature context` 做了增强。

它会输出：

- 当前 `context_mode`；
- 当前 stage 必须读的 `must_read`；
- 只有需要时才读的 `optional_files`。

例如 dispatch 阶段，重点读：

```text
tasks.md
dispatch.md
model-routing.md
```

测试阶段才读：

```text
test-cases.md
test-results.md
implementation/test.md
```

人工验收阶段才集中看：

```text
project-docs/04_MANUAL_ACCEPTANCE.md
```

这让 AgentFlow 的上下文策略从“文件越来越多”，转向“按阶段精确读取”。

## 1.1.0 的关键词：分层和分级

1.1.0 的变化放在一起看，核心不是“让 AI 更自动化”，而是“让 AI 协作更分层”。

测试分层：

```text
AI 测试同步执行
人工验收异步集中处理
```

模型分级：

```text
low / medium / high / extra-high
```

流程分层：

```text
stage routing
dispatch task routing
```

上下文分层：

```text
must_read
optional_files
```

执行分层：

```text
先生成 plan
再人工确认是否 execute
```

这些变化的目标都一样：

**让长期 AI 协作既能自动推进，又不失控。**

## 1.1.1：把架构决策前置到 feature 拆分之前

做完 1.0.0 和 1.1.0 之后，Manager 已经能恢复状态、跑流程、分派任务、区分 AI 测试和人工验收，也能根据任务难度选择不同 reasoning 档位。

但这里还有一个更上游的问题：

**如果项目架构本身没有先定下来，feature 拆得越快，后面返工越多。**

真实项目里，很多问题不是出现在实现阶段，而是在需求刚导入时就已经决定了：

- 这是纯后端项目，还是 Web + 后端？
- 是否需要移动端？
- 是否需要多租户？
- 权限模型是简单角色，还是细粒度 RBAC？
- 数据库、缓存、对象存储、消息队列是否需要提前考虑？
- 是从零实现用户系统，还是引入已有模块？
- 部署方式是普通云服务，还是私有化、本地化、内网环境？

这些问题如果不先处理，Manager 很容易直接进入：

```text
读取需求
-> 拆 feature
-> 写 spec
-> 写 plan
-> 派 subagent
```

看起来流程很快，但方向可能是错的。

所以 1.1.1 补了一道新的项目级关卡：

```text
需求文档
-> 架构分析
-> 架构确认
-> 配置建议
-> 模块判断
-> feature 拆分
```

## 一、01_ARCHITECTURE 不再只是说明文档

之前项目里已经有：

```text
project-docs/01_ARCHITECTURE.md
```

但它更像一个普通说明模板。

1.1.1 之后，它变成了正式的架构决策文档。

里面会记录：

- Architecture Status；
- 需求输入来源；
- 项目形态；
- 推荐架构；
- 备选方案；
- 关键架构决策；
- 模块边界；
- 数据流；
- API 边界；
- 配置影响；
- feature 拆分影响；
- 风险；
- 待确认问题。

其中最关键的是状态：

```text
Status: draft
Status: approved
Status: needs-revision
```

这意味着架构不再是“AI 随便写一段背景说明”。

它有明确状态。

在完整项目拆分之前，Manager 应该先把它写成 draft，再让用户确认，确认后改成 approved。

## 二、不是一开始反问一堆问题，而是先给推荐方案

这个机制不是为了让用户在开工前填一张很长的调查问卷。

更合理的流程是：

```text
Manager 先读需求
-> 自动生成架构初稿
-> 把不确定点写进 Open Questions
-> 只追问会影响架构方向的问题
```

比如这些问题值得问：

- 是否已有指定技术栈？
- 是否必须私有化部署？
- 是否有多租户或严格权限隔离？
- 是否有合规、审计、数据安全要求？
- 是否必须支持移动端？

但很多细节不需要一开始打断用户。

可以先写进 `Open Questions`，后续 plan 或 feature 阶段再逐步收敛。

这避免了两个极端：

- AI 不问任何问题，直接拍脑袋拆任务；
- AI 一开始问几十个问题，把用户卡在流程外。

1.1.1 选择的是中间路线：

**先给出可执行的推荐架构，再只确认真正会影响方向的决策。**

## 三、新增 architecture check

为了让这件事不只是提示词约束，1.1.1 还加了一个 CLI 检查：

```bash
agentflow architecture check
```

它会检查：

- `project-docs/01_ARCHITECTURE.md` 是否存在；
- `Status` 是否为 `approved`；
- 是否还包含 `TBD` 或模板占位符。

如果没有通过，它会明确告诉 Manager：

```text
Architecture is not approved.
Open architecture placeholders:
...
```

这里刻意没有让 `feature create` 硬性失败。

原因是：已有项目里临时加一个很小的 feature，或者补一个 bug 修复，不应该被一个项目级架构文档强行挡住。

所以现在的策略是：

- 完整项目拆分：Manager 必须先完成架构确认；
- 单个临时 feature：CLI 给 warning，但不阻断。

这让规则足够明确，又不会破坏日常灵活性。

## 四、配置建议必须来自已确认架构

1.0.0 里已经强调过，Manager 导入需求后应该主动提出配置建议。

1.1.1 进一步明确：

配置建议不应该只来自零散需求关键词，而应该来自已确认的架构判断。

例如：

```text
架构确认：项目只有 Web 前端和后端，没有移动端
-> implementation.target_sides 删除 mobile
```

或者：

```text
架构确认：涉及用户、权限、租户隔离
-> workflow.default_type 保持 standard
-> 权限相关 feature 使用 sensitive
-> review gate 保持开启
-> manual acceptance 放到 release 级别
```

这样配置不再只是“AI 猜到什么改什么”。

它有上游依据：

```text
需求
-> 架构决策
-> 配置影响
-> feature 拆分
```

这条链路会写在本地文件里，后续新会话、新 Manager 或新 subagent 都能读到。

## 五、feature 拆分要受架构影响

架构文档里还新增了一个很重要的部分：

```text
Feature Planning Implications
```

它回答的是：

- 哪些 milestone 应该先拆？
- 哪些 feature 是高风险？
- 哪些 feature 可以走 trivial / standard？
- 哪些外部模块应该先登记和评估？

比如一个项目如果确认要复用已有用户模块，那么“用户系统”就不应该再被拆成一组从零实现的 feature。

它应该变成：

```text
模块登记
-> 复用风险评估
-> 集成适配
-> 权限边界测试
-> 人工验收项
```

这就是架构前置的价值：

它不只是决定“用什么技术”，还会影响“怎么拆活”。

## 1.1.1 的关键词：先定方向，再拆任务

1.1.1 看起来只是补了一份架构文档和一个检查命令，但它解决的是很上游的问题。

在 AI 协作里，速度很容易掩盖方向问题。

AI 很擅长快速拆 feature、写 spec、写 tasks、开 subagent。

但如果架构方向没确认，这些产物越多，后面越难改。

所以 1.1.1 的关键词是：

- 架构初稿；
- 人工确认；
- approved 状态；
- architecture check；
- 配置影响；
- feature planning implications；
- 先定方向，再拆任务。

它让 AgentFlow 的流程又往前移了一步：

不只是守住 feature 内部的阶段，也开始守住项目启动时的方向决策。

## 这三次迭代合在一起意味着什么

0.6.0 让 AgentFlow 更像一个本地工程守卫器。

1.0.0 让这个守卫器能被 Manager 日常使用。

1.1.0 则让 Manager 不只是“继续流程”，还开始具备更细的调度能力：

- 哪些测试 AI 必须做；
- 哪些验收应该留给人；
- 哪些任务用低档 reasoning；
- 哪些任务必须提升到 extra-high；
- 哪些文件当前必须读；
- 哪些文件不要每轮都读；
- 哪些 subagent prompt 可以先生成计划，再决定是否执行。

1.1.1 则继续把流程往上游推进：

- 需求导入后先生成架构建议；
- 不确定点进入 Open Questions；
- 只追问真正影响架构方向的问题；
- 架构确认后才能进入完整项目 feature 拆分；
- 配置建议和 feature 表都要有架构依据。

这说明 Lang AgentFlow Kit 的方向更加明确：

它不是要替代 Codex 或 Claude Code。

它也不是要做一个封闭的多 agent 平台。

它更像是本地项目里的 AI 协作协议层：

```text
状态在本地
规则在本地
记录在本地
分派依据在本地
执行 adapter 可替换
```

## 仍然保留的边界

当然，1.1.1 之后它仍然不是“全自动多 Agent 系统”。

当前 Codex adapter 主要是：

- 生成 prompt；
- 生成计划；
- 生成执行脚本；
- 在显式 `--execute` 时调用 Codex。

Claude Code、Gemini CLI 或其他工具，还需要各自的 adapter。

这也是刻意保留的边界。

因为不同工具的模型选择、会话管理、权限控制、文件写入方式都不一样。

AgentFlow 核心不应该把这些差异硬编码进去。

它只应该维护统一的中性语义：

```text
这个 task 是什么角色？
风险是什么？
复杂度是什么？
需要什么 reasoning 档位？
架构依据是什么？
应该读哪些文件？
应该写回哪里？
```

至于怎么启动某个 AI 工具，让 adapter 去处理。

## 小结

Lang AgentFlow Kit 1.0.0、1.1.0 和 1.1.1 的三次迭代，可以看成一个连续变化：

**从“能守住流程”，走向“能接住长期协作”。**

1.0.0 让 Manager 工作流稳定下来。

用户不需要记命令，只需要用短句表达意图。

Manager 负责读规则、跑检查、更新状态和输出心跳。

1.1.0 则继续把真实项目里的复杂性拆开：

- AI 测试和人工验收分开；
- feature 和 task 的模型档位分开；
- spec / plan / tasks 和实现分派都纳入路由；
- Codex adapter 先生成计划，再显式执行；
- active context 按阶段减少不必要读取。

1.1.1 则把项目启动时最容易被忽略的架构决策单独拎出来：

- 先写架构初稿；
- 再确认关键方向；
- 再改配置；
- 最后才拆 feature。

这三次迭代并没有把工具变成一个更“魔法”的自动平台。

相反，它让工具更像一个耐用的本地协作层。

AI 可以更主动。

流程可以更可控。

人也不需要被迫参与每一个机械步骤。

这可能才是长期 AI 辅助开发真正需要的方向：

不是让 AI 无限制地自动跑，而是让 AI 在清晰的本地协议里，知道什么时候该做、做什么、用多强的能力做、架构依据是什么、做完记录在哪里，以及什么时候必须停下来等人确认。
