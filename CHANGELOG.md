# Changelog

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
