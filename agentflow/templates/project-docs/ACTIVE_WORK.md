# Active Work

This file is the resume point for humans and AI Managers.

New session instruction:

```text
You are the Manager. Read AGENTS.md and project-docs/ACTIVE_WORK.md, then continue the current work.
```

## Resume Summary

- Current Feature: TBD
- Current Stage: TBD
- Current Task: TBD
- Current Owner Role: Manager
- Work Status: not-started
- Human Needed: no
- Last Updated: TBD

## Current Work Queue

| Task | Title | Owner | Backend | Frontend | Mobile | Test | Status | Next |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TBD | TBD | Manager | n/a | n/a | n/a | n/a | not-started | Define the first feature |

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

- TBD

## Last Checks Run

Record the commands the Manager or hooks actually ran.

```text
TBD
```

## Current Blockers

- TBD

## Next Action

TBD

## Human Decision Needed

- No

## Heartbeat

The Manager must end each work session according to `manager.heartbeat_mode` in
`agentflow.config.yml`.

Compact session output:

```text
AI为你保驾护航 | checks: no | active_work: no | next: TBD | human: no
```

Full state record:

```yaml
heartbeat_phrase: AI为你保驾护航
anchor_pulse:
  current_feature: TBD
  current_stage: TBD
  current_task: TBD
  checks_run: no
  active_work_updated: no
  next_action_clear: no
  human_needed: no
```

If the phrase or state is missing, the next session should re-read `AGENTS.md`,
`agentflow.config.yml`, and this file before continuing.
