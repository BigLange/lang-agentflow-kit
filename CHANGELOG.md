# 变更日志

## Unreleased

### 新增

- 在 `.agentflow/modules/` 下新增 External Module Governance registry。
- 新增 `agentflow module list`、`show`、`add`、`contract` 和 `approve`。
- 新增 `agentflow reuse analyze` 和 `agentflow reuse gate`。
- 新增针对公共模块 direct-copy、公共高风险 vendor、公共 critical-domain reuse 的静态策略检查。
- 新增 feature 级 `reuse-analysis.md` 和 `external-module-risk.md` 生成。
- 新增外部模块 smoke test。

## 0.6.0 - 2026-06-05

工程 guardrail 和 state 加固版本。

### 新增

- 在 `features/FEATURE-XXX/state.yml` 中新增 per-feature state files。
- 新增 `agentflow state migrate`，用于将旧全局 feature state 拆分为 feature-local state files。
- 新增生成任务板头部和 `agentflow board render --check`。
- 新增 dynamic workflows 的 feature types：`trivial`、`bug`、`standard`、`major` 和 `sensitive`。
- 新增 `agentflow doctor`，用于本地 runtime 和项目健康检查。
- 新增 `agentflow check --all`，用于 CI-friendly 项目健康检查。
- 新增 warning-mode `agentflow install-hooks`，用于 Git pre-commit 和 pre-push hooks。
- 新增 `agentflow init-ci github`，用于生成 GitHub Actions guardrail workflow。
- 新增 `agentflow init-rules cursor|cline|codex|all`，用于 IDE/agent rule files。
- 新增用于 sensitive feature reuse review 的 external module governance templates。
- 新增 `agentflow --version` 和 `agentflow version`，版本来源为 `package.json`。
- 新增 smoke test script，覆盖初始化、feature 创建、board freshness、context、gate 和 doctor checks。

### 变更

- `project-docs/03_TASK_BOARD.md` 现在从 feature-local state 生成。
- `.agentflow/state/features.yml` 不再是 canonical source of truth。
- `agentflow check --all` 现在执行 stage-aware health checks，而不是因为 draft feature 中的占位符失败。
- `agentflow init` 不再覆盖已有配置，除非使用 `--force`。
- README 已重写为更简洁的开源入口文档，包含 quick start、platform support、limitations 和 docs links。

## 0.5.0 - 2026-05-27

Review isolation 加固版本。

### 新增

- 新增 `review.<stage>.mode` 配置，支持 `self`、`separate-session` 和 `human`。
- 新增 `separate-session` review metadata 的 gate checks。
- 新增 `agentflow approve FEATURE --stage <stage>`，用于写入 CLI 生成的 human approval metadata。
- Review templates 现在包含最小 review metadata section。

### 变更

- `review.mode=self` 保持兼容，但会输出 weak-isolation warning。
- `review.mode=human` 需要 CLI approval metadata，而不是信任手写 human sign-off。
- `full` profile 默认使用比 `standard` 更强的 review isolation。

## 0.4.0 - 2026-05-27

State-backed board rendering 版本。

### 新增

- 新增 `.agentflow/state/features.yml`，作为项目任务板的源数据。
- 新增 `agentflow board render`，从 state 重新生成 `project-docs/03_TASK_BOARD.md`。
- Feature creation 现在会将新 feature 写入 state 并渲染 board。

### 变更

- `project-docs/03_TASK_BOARD.md` 现在被视为渲染输出，而不是 canonical feature state source。
- `feature archive` 更新 feature state 并渲染 board，而不是直接追加 Markdown。
- Git hygiene 现在保留 `.agentflow/state/features.yml` 版本控制，同时忽略其他生成 runtime state。

## 0.3.0 - 2026-05-27

YAML-driven execution、gate semantics 和 active context 的加固版本。

### 新增

- 新增从 effective config 驱动的 YAML-driven feature generation and checks。
- 新增 `implementation.target_sides`，用于选择 backend/frontend/mobile result。
- 新增 canonical no-mutation gate command：`agentflow gate STAGE FEATURE`。
- 新增 Markdown active context 输出：`.agentflow/state/active_context.md`。
- 增强 active context 字段，覆盖 goal、required files、must-read files、forbidden actions、next step、open questions 和 current blockers。

### 变更

- `agentflow check FEATURE` 现在会因为明显占位符失败，不只检查缺失文件。
- Pure gate checks 会输出稳定的 `Gate Decision` 和 `Blockers`，且不写 context、不同步 tasks、不 archive。
- Stage gates 现在检查更明确的 stage-specific readiness rules。
- `feature context` 继续写 JSON，并新增 Markdown，作为推荐给 agent 的 first-read contract。

## 0.2.0 - 2026-05-27

Runtime guardrails 版本。

### 背景

该版本解决早期 Markdown-only workflow 的主要弱点：agent 能生成正确文件，但在长期、多 agent 工作中仍可能丢失阶段状态。Spec 可能仍含占位符时就开始实现，review 文件可能停留在 pending，任务板也可能偏离 feature 的真实 readiness。

`0.2.0` 新增轻量 runtime checks，使 feature state 可以在不替代 Markdown workflow 的前提下被检查、阻塞、刷新和交接。

### 新增

- 新增 `agentflow feature verify FEATURE --stage <stage>`，用于 deterministic stage verification。
- 新增 `agentflow feature gate FEATURE --to <stage>`，用于 hard stage transitions。
- 新增 `agentflow feature context FEATURE`，用于生成 active runtime context。
- 新增 `agentflow feature next FEATURE`，用于日常 gate/sync/context/status 推进。
- 新增 `agentflow feature status FEATURE`，显示 current stage、next gate、task progress、records state 和 blockers。
- 新增 runtime config sections：`complexity_profile`、`runtime`、`hooks` 和 `gates`。
- 新增 `before_<stage>` 和 `after_<stage>` command hooks 支持。
- 新增 implementation fix、test、review、result 和 archive records 的 feature templates。
- 新增 review、test 和 done summary record templates。
- 新增 `docs/config-schema.md`，包含 runtime-read keys、stage model、output examples、records policy 和 migration notes。
- 新增 `docs/lang-agentflow-kit-introduction.md`，作为较长产品介绍。
- 新增 `docs/runtime-guardrails-todo.md`，用于 runtime guardrails TODO/status tracking。
- 新增 demo feature bundles 和 project docs，展示当前 blocked-before-plan 状态。

### 变更

- README 现在将 AgentFlow 定位为 Markdown contract + lightweight runtime guardrails。
- Manager 和 project AGENTS templates 现在将 CLI status/gate/context output 视为 runtime stage state 的事实来源。
- Git hygiene 默认忽略 generated runtime state 和 transient dispatch logs。
- Feature task flow 现在区分 `archive` 和 `done`。

### 说明

- `0.2.0` 尚不会自动运行 spec-kit、Oh My Codex 或 spawn all subagents。
- Per-stage structured gate schema 被记录为未来方向；当前 CLI 仍读取全局 `gates:` booleans。
