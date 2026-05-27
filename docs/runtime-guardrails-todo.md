# Runtime Guardrails TODO

## Goal

Turn Lang AgentFlow Kit from a Markdown-only workflow contract into a
protocol engine with lightweight runtime guardrails.

The target is not "support every coding scenario".

The target is:

- long-running AI-assisted software projects
- complex features with multi-stage handoff
- reduced context drift and protocol forgetting
- stronger stage enforcement without replacing Markdown workflows

## Scope

Keep:

- `AGENTS.md`
- `project-docs/`
- Feature Bundle contracts
- natural language and Markdown collaboration

Add:

- runtime verification
- stage gates
- active context state
- optional hooks
- clearer complexity profiles

Do not do yet:

- full external orchestrator runtime
- automatic spec-kit execution
- heavy daemon or service architecture
- replacing Markdown with a database or UI-first workflow

## Phase 0: Positioning And Contract Cleanup

- [x] Rewrite the root `README.md` positioning around complex, long-running AI projects.
- [x] Explicitly document non-goals: small fixes, one-off scripts, quick vibe coding.
- [x] Clarify that current stable assets are the Feature Bundle contract and records contract.
- [x] Document the difference between protocol constraints and runtime constraints.
- [x] Add a short architecture note for "Markdown contract + lightweight runtime guardrails".

## Phase 1: Config Schema Upgrade

- [x] Extend `agentflow.config.yml` instead of moving config paths immediately.
- [x] Add `complexity_profile` support. Current template value: `standard`.
- [ ] Add explicit `stages` configuration. Deferred until the v1 global gate model proves insufficient.
- [x] Document structured per-stage `gates` as a future schema direction while keeping current global gate flags.
- [x] Add `state` configuration for generated runtime state files.
- [x] Add `hooks` configuration for optional stage commands.
- [x] Keep backward compatibility with existing `lite / standard / full` templates.
- [ ] Define a migration path only after the new schema is stable.

## Phase 2: Stage Model

- [x] Define the canonical stage order in CLI behavior.
- [x] Define stage entry requirements through `gate`.
- [x] Define stage completion requirements through `verify`.
- [x] Define stage outputs that are mandatory vs optional in `README.md` and `docs/config-schema.md`.
- [x] Decide first-pass human-reviewable vs machine-verifiable policy: review files remain human-authored, while runtime verifies their structural completion.

Recommended first-pass stages:

- `spec`
- `plan`
- `tasks`
- `dispatch`
- `implement`
- `test`
- `review`
- `fix`
- `archive`

## Phase 3: `agentflow verify`

- [x] Add `agentflow verify FEATURE-XXX --stage <stage>`.
- [x] Add daily namespace alias: `agentflow feature verify FEATURE-XXX --stage <stage>`.
- [x] Verify required files exist for a stage.
- [x] Verify obvious placeholders like `TBD` or raw template leftovers are gone.
- [x] Verify review checklist sections are completed where required.
- [x] Verify archive/test/review records exist where required.
- [x] Return clear failure messages that tell the user what is missing.
- [x] Keep the first version rule-based and deterministic.

First-pass verification rules:

- `spec`: `spec.md` exists, has no open placeholders, `spec-review.md` gate completed.
- `plan`: `plan.md` exists, depends on passed `spec`, `plan-review.md` gate completed.
- `tasks`: `tasks.md` exists, depends on passed `plan`, `task-review.md` gate completed.
- `dispatch`: `dispatch.md` exists and has task ownership rows.
- `archive`: `archive.md` exists and references implementation, test, and review outputs.

## Phase 4: `agentflow gate`

- [x] Add `agentflow gate FEATURE-XXX --to <stage>`.
- [x] Add daily namespace alias: `agentflow feature gate FEATURE-XXX --to <stage>`.
- [x] Block transitions when prerequisite stages fail verification.
- [x] Make gate output readable enough for both humans and agents.
- [x] Reuse `verify` logic instead of duplicating checks.
- [x] Decide whether `dispatch` and `archive` should hard-fail on unmet gates by default. Current config defaults: `enforce_dispatch_gate: true`, `enforce_archive_gate: true`.

Recommended first hard gates:

- [x] Prevent entering `plan` before `spec` passes.
- [x] Prevent entering `tasks` before `plan` passes.
- [x] Prevent `dispatch` before `tasks` passes.
- [x] Prevent `archive` before required test/review artifacts pass.

## Phase 5: Runtime State And `agentflow context`

- [x] Add `.agentflow/state/` as generated runtime state output.
- [x] Add `agentflow context FEATURE-XXX`.
- [x] Add daily namespace alias: `agentflow feature context FEATURE-XXX`.
- [x] Generate `.agentflow/state/active_context.json`.
- [x] Keep the file generated from Markdown, never hand-maintained.
- [x] Include current feature, current stage, next gate, open tasks, and key files.
- [x] Keep the JSON intentionally small so agents can consume it cheaply.

The active context should answer:

- What am I working on?
- Which stage am I in?
- What must be true before I can move on?
- Which files matter right now?
- What is the next blocking action?

## Phase 6: Hook System

- [x] Support optional stage hooks in config.
- [x] Add before/after stage hook keys in config.
- [x] Allow commands like tests, lint, and `agentflow verify`.
- [x] Define hook failure behavior through `runtime.hook_failure_policy`.
- [x] Ensure hooks are optional so the CLI stays lightweight.

Example shape:

```yaml
hooks:
  after_plan:
    - agentflow verify FEATURE-001-demo --stage plan
  after_implement:
    - npm test
    - agentflow verify FEATURE-001-demo --stage implement
```

## Phase 7: Git Hygiene

- [x] Separate durable project knowledge from high-frequency runtime state.
- [x] Keep architecture/spec/plan/tasks/archive in Git by default.
- [x] Move transient runtime artifacts under `.agentflow/state/`.
- [x] Decide whether `project-docs/records/dispatch/` stays durable or becomes transient. Default policy: transient unless the project requires a full audit trail.
- [x] Add recommended `.gitignore` guidance for generated runtime state.

## Phase 8: Template And Prompt Alignment

- [x] Update `AGENTS.md` templates to point agents toward runtime commands.
- [x] Update Manager role instructions to rely on CLI gate checks, not memory alone.
- [x] Update feature templates to make checklist completion machine-checkable.
- [x] Remove language that implies the workflow is enforced purely by discipline.

## Phase 9: Documentation And Examples

- [x] Add a runtime guardrails section to `README.md`.
- [x] Add examples of passing vs failing verify output.
- [ ] Add an example strict project config. Deferred until per-stage schema is implemented, because `complexity_profile: strict` is currently descriptive.
- [x] Add a migration note for existing users of the current Markdown-only flow.

## Implementation Order

1. [x] Positioning update in `README.md`
2. [x] Config schema extension
3. [x] Stage model definition in CLI behavior
4. [x] `agentflow verify`
5. [x] `agentflow gate`
6. [x] `agentflow context`
7. [x] Hook support
8. [x] Git hygiene and template cleanup

## Immediate Next Tasks

- [x] Confirm the first milestone only covers `verify`, `gate`, and `context`.
- [x] Decide the first supported stages for hard enforcement.
- [x] Decide whether `dispatch` should hard-fail immediately or stay soft in v1. Current default is hard-fail.
- [x] Decide whether runtime state should be checked into Git in this repo demo. Current `.gitignore` policy excludes `.agentflow/state/`.

## Current Runtime Status

Checked on 2026-05-27 with `bin/agentflow feature status`:

| Feature | Runtime Stage | Next Gate | Progress | Status |
| --- | --- | --- | --- | --- |
| `FEATURE-001-feature` | `draft` | `plan` | 0% | blocked: spec placeholders and pending spec review |
| `FEATURE-002-feature` | `draft` | `plan` | 0% | blocked: spec placeholders and pending spec review |

## Optimization Backlog

- [x] Document the stage model outside `bin/agentflow` so users do not need to read shell code to understand the contract.
- [x] Decide whether `gates:` should stay as global booleans or become per-stage structured rules. Decision: keep global booleans for v1; document per-stage rules as future schema.
- [x] Add passing and failing examples for `feature verify`, `feature gate`, `feature status`, and `feature next`.
- [x] Clarify records policy: which records are durable project history and which are transient runtime artifacts.
- [x] Tighten Manager and role instructions so agents use runtime commands as the source of truth.
- [ ] Add a strict config example once the schema stabilizes.
- [x] Add migration guidance for projects initialized before runtime guardrails.

## Next-Stage Hardening Roadmap

The next optimization stage is tracked in:

- [next-stage-hardening-roadmap.md](./next-stage-hardening-roadmap.md)

Priority order:

1. YAML-driven execution
2. Gate system hardening
3. Active context hardening
4. State-backed board rendering
5. Review isolation
6. Optional small engine extraction
