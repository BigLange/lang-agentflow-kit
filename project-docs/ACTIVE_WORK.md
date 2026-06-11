# Active Work

This file is the resume point for humans and AI Managers.

New session instruction:

```text
You are the Manager. Read AGENTS.md and project-docs/ACTIVE_WORK.md, then continue the current work.
```

## Resume Summary

- Current Feature: none
- Current Stage: documentation
- Current Task: simplify AgentFlow usage and add resume workflow
- Current Owner Role: Manager
- Work Status: ready-for-review
- Human Needed: yes
- Last Updated: 2026-06-11

## Current Work Queue

| Task | Title | Owner | Backend | Frontend | Mobile | Test | Status | Next |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DOC-001 | Add ACTIVE_WORK resume workflow | Manager | n/a | n/a | n/a | check-passed | ready-for-review | human review, then commit if approved |

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

## Last Checks Run

```text
npm run check: passed
agentflow init smoke in /tmp: passed, annotated agentflow.config.yml and project-docs/ACTIVE_WORK.md generated
agentflow feature create/status smoke in /tmp: passed with manager.heartbeat_phrase present
npm run check: passed after user workflow documentation updates
npm run check: passed after YAML AI-comment updates
```

## Current Blockers

- None.

## Next Action

Human review, then commit and push if requested.

## Human Decision Needed

- Yes: review the YAML AI-comment workflow and decide whether to commit.

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
