# Active Work

This file is the resume point for humans and AI Managers.

New session instruction:

```text
You are the Manager. Read AGENTS.md and project-docs/ACTIVE_WORK.md, then continue the current work.
```

## Resume Summary

- Current Feature: none
- Current Stage: documentation
- Current Task: add update command for existing AgentFlow projects
- Current Owner Role: Manager
- Work Status: ready-for-review
- Human Needed: yes
- Last Updated: 2026-06-23

## Current Work Queue

| Task | Title | Owner | Backend | Frontend | Mobile | Test | Status | Next |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DOC-001 | Add ACTIVE_WORK resume workflow | Manager | n/a | n/a | n/a | check-passed | ready-for-review | human review, then commit if approved |
| RUNTIME-001 | Add testing assets, manual acceptance, model routing, and Codex adapter | Manager | n/a | n/a | n/a | check-passed | ready-for-review | human review, then commit if approved |

Status values:

- `not-started`
- `in-progress`
- `blocked`
- `waiting-backend`
- `waiting-frontend`
- `waiting-mobile`
- `waiting-test`
- `waiting-review`
- `done`

## Last Completed Work

- Added `agentflow/templates/project-docs/ACTIVE_WORK.md`.
- Updated `bin/agentflow` so init creates `project-docs/ACTIVE_WORK.md` when missing.
- Updated Manager and project rules to use ACTIVE_WORK and configurable heartbeat phrase / anchor pulse.
- Updated README, user manual, config guide, config reference, and product introduction.
- Added AI Manager instructions to config templates and current `agentflow.config.yml`.
- Added configurable `manager.heartbeat_phrase` with default `AI为你保驾护航`.
- Documented that AI can help edit YAML config and that short Manager prompts can be persisted in AGENTS.md/CLAUDE.md-style rule files.
- Added Chinese YAML comments that tell AI when to suggest config changes, wait for confirmation, edit YAML, validate syntax, run checks, and update ACTIVE_WORK.
- Updated docs to clarify that compact heartbeat is the default and full `anchor_pulse` only appears when `manager.heartbeat_mode: full`.
- Reworked `docs/user-manual.md` around short user intents, Manager follow-up questions, automatic CLI/check execution, third-party module intake, and simplified test/review/archive explanation.
- Added `.agentflow/skills/agentflow-manager-workflow` as the durable place for fixed Manager workflows.
- Added Skill frontmatter triggers and a confirmation protocol so short user intents trigger Manager workflows and AI asks for missing decisions.
- Added requirement-intake flow: after requirements are imported, Manager must infer YAML config, identify third-party module candidates, ask for confirmation, and adjust feature planning when modules are imported.
- Clarified feature finish flow: Manager should automatically start test/review/archive when implementation is complete, delegate detailed work to focused roles, and keep Manager context small.
- Bumped package and docs version from 0.6.0 to 1.0.0 to mark the stabilized Manager workflow release.
- Added feature-level AI test assets: `test-cases.md`, `test-results.md`, and `manual-acceptance.md`.
- Added project-level manual acceptance board: `project-docs/04_MANUAL_ACCEPTANCE.md`.
- Added `model-routing.md` with stage routing and dispatch task routing.
- Added neutral reasoning profiles: `low`, `medium`, `high`, and `extra-high`.
- Added Codex stage and dispatch plan/run adapter commands.
- Added stage-aware active context fields to reduce repeated prompt reading.
- Bumped package and docs version from 1.0.0 to 1.1.0.
- Added `agentflow update --check` and `agentflow update --apply` for existing projects.
- Bumped package and docs version from 1.1.0 to 1.1.1.

## Last Checks Run

```text
npm run check: passed
agentflow init smoke in /tmp: passed, annotated agentflow.config.yml and project-docs/ACTIVE_WORK.md generated
agentflow feature create/status smoke in /tmp: passed with manager.heartbeat_phrase present
npm run check: passed after user workflow documentation updates
npm run check: passed after YAML AI-comment updates
npm run check: passed after Manager workflow manual rewrite
agentflow init --profile standard smoke: passed, agentflow-manager-workflow skill copied
npm run check: passed after Skill trigger/confirmation protocol update
agentflow init --profile standard smoke: passed with Skill frontmatter copied
npm run check: passed after requirement-intake config/module flow update
npm run check: passed after automatic finish/delegation update
npm run check: passed after 1.0.0 version bump
npm run check: passed after test/model-routing/Codex adapter updates
npm run smoke: passed after test/model-routing/Codex adapter updates
npm run smoke:external-modules: passed after test/model-routing/Codex adapter updates
npm run check: passed after update command
npm run smoke: passed after update command
npm run smoke:external-modules: passed after update command
```

## Current Blockers

- None.

## Next Action

Human review, then commit and push if requested.

## Human Decision Needed

- Yes: review the simplified Manager workflow manual and decide whether to commit.

## Heartbeat

Compact session output:

```text
AI为你保驾护航 | checks: yes | active_work: yes | next: human review, commit if requested | human: yes
```

Full state record:

```yaml
heartbeat_phrase: AI为你保驾护航
anchor_pulse:
  current_feature: none
  current_stage: documentation
  current_task: DOC-001
  checks_run: yes
  active_work_updated: yes
  next_action_clear: yes
  human_needed: yes
```
