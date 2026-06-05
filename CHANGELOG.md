# Changelog

## Unreleased

### Added

- External Module Governance registry under `.agentflow/modules/`.
- `agentflow module list`, `show`, `add`, `contract`, and `approve`.
- `agentflow reuse analyze` and `agentflow reuse gate`.
- Static policy checks for public module direct-copy, public high-risk vendor,
  and public critical-domain reuse.
- Feature-level `reuse-analysis.md` and `external-module-risk.md` generation.
- External module smoke test.

## 0.6.0 - 2026-06-05

Engineering guardrail and state hardening release.

### Added

- Per-feature state files at `features/FEATURE-XXX/state.yml`.
- `agentflow state migrate` to split legacy global feature state into feature-local state files.
- Generated task board header and `agentflow board render --check`.
- Feature types for dynamic workflows: `trivial`, `bug`, `standard`, `major`, and `sensitive`.
- `agentflow doctor` for local runtime and project health checks.
- `agentflow check --all` for CI-friendly project health checks.
- Warning-mode `agentflow install-hooks` for Git pre-commit and pre-push hooks.
- `agentflow init-ci github` for GitHub Actions guardrail workflow generation.
- `agentflow init-rules cursor|cline|codex|all` for IDE/agent rule files.
- External module governance templates for sensitive feature reuse review.
- `agentflow --version` and `agentflow version`, sourced from `package.json`.
- Smoke test script for initialization, feature creation, board freshness, context, gate, and doctor checks.

### Changed

- `project-docs/03_TASK_BOARD.md` is now generated from feature-local state.
- `.agentflow/state/features.yml` is no longer the canonical source of truth.
- `agentflow check --all` now performs stage-aware health checks instead of failing draft features for placeholders.
- `agentflow init` no longer overwrites existing config unless `--force` is used.
- README was rewritten as a concise open-source entry document with quick start, platform support, limitations, and docs links.

## 0.5.0 - 2026-05-27

Review isolation hardening release.

### Added

- `review.<stage>.mode` config for `self`, `separate-session`, and `human`.
- Gate checks for `separate-session` review metadata.
- `agentflow approve FEATURE --stage <stage>` for CLI-written human approval
  metadata.
- Review templates now include a minimal review metadata section.

### Changed

- `review.mode=self` remains compatible but emits a weak-isolation warning.
- `review.mode=human` requires CLI approval metadata instead of trusting
  hand-written human sign-off.
- The `full` profile defaults to stronger review isolation than `standard`.

## 0.4.0 - 2026-05-27

State-backed board rendering release.

### Added

- `.agentflow/state/features.yml` as the source data for the project task board.
- `agentflow board render` to regenerate `project-docs/03_TASK_BOARD.md` from state.
- Feature creation now records new features in state and renders the board.

### Changed

- `project-docs/03_TASK_BOARD.md` is now treated as rendered output instead of
  the canonical feature state source.
- `feature archive` updates feature state and renders the board instead of
  appending directly to Markdown.
- Git hygiene now keeps `.agentflow/state/features.yml` versioned while other
  generated runtime state remains ignored.

## 0.3.0 - 2026-05-27

Hardening release for YAML-driven execution, gate semantics, and active context.

### Added

- YAML-driven feature generation and checks from effective config.
- `implementation.target_sides` for backend/frontend/mobile result selection.
- Canonical no-mutation gate command: `agentflow gate STAGE FEATURE`.
- Markdown active context output at `.agentflow/state/active_context.md`.
- Stronger active context fields for goal, required files, must-read files,
  forbidden actions, next step, open questions, and current blockers.

### Changed

- `agentflow check FEATURE` now fails on obvious placeholders, not only missing files.
- Pure gate checks report stable `Gate Decision` and `Blockers` output without
  writing context, syncing tasks, or archiving.
- Stage gates now check more explicit stage-specific readiness rules.
- `feature context` continues writing JSON and now also writes Markdown as the
  recommended first-read contract for agents.

## 0.2.0 - 2026-05-27

Runtime guardrails release.

### Rationale

This release addresses the main weakness of the earlier Markdown-only workflow:
agents could generate the right files but still lose track of stage state during
long, multi-agent work. Specs could contain placeholders while implementation
started, review files could remain pending, and task boards could drift away
from actual feature readiness.

`0.2.0` adds lightweight runtime checks so feature state can be inspected,
blocked, refreshed, and handed off without replacing the Markdown workflow.

### Added

- `agentflow feature verify FEATURE --stage <stage>` for deterministic stage verification.
- `agentflow feature gate FEATURE --to <stage>` for hard stage transitions.
- `agentflow feature context FEATURE` for generated active runtime context.
- `agentflow feature next FEATURE` for daily gate/sync/context/status progression.
- `agentflow feature status FEATURE` for current stage, next gate, task progress, records state, and blockers.
- Runtime config sections for `complexity_profile`, `runtime`, `hooks`, and `gates`.
- Hook support for `before_<stage>` and `after_<stage>` commands.
- Feature templates for implementation fix, test, review, result, and archive records.
- Summary record templates for review, test, and done records.
- `docs/config-schema.md` with runtime-read keys, stage model, output examples, records policy, and migration notes.
- `docs/lang-agentflow-kit-introduction.md` as a longer product introduction.
- Runtime guardrails TODO/status tracking under `docs/runtime-guardrails-todo.md`.
- Demo feature bundles and project docs showing current blocked-before-plan status.

### Changed

- README now positions AgentFlow as a Markdown contract plus lightweight runtime guardrails.
- Manager and project AGENTS templates now treat CLI status/gate/context output as the source of truth for runtime stage state.
- Git hygiene defaults now ignore generated runtime state and transient dispatch logs.
- Feature task flow now distinguishes `archive` from `done`.

### Notes

- `0.2.0` does not yet auto-run spec-kit, Oh My Codex, or spawn all subagents.
- Per-stage structured gate schema is documented as a future direction; current CLI still reads global `gates:` booleans.
