# Changelog

## 0.2.0 - 2026-05-27

Runtime guardrails release.

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
