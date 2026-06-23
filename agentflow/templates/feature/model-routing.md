# Model Routing: {{FEATURE_TITLE}}

## Status

Status: draft

## Feature Defaults

- Feature type: {{FEATURE_TYPE}}
- Default model profile: {{MODEL_PROFILE}}
- Routing reason: {{ROUTING_REASON}}

## Task Routing

## Stage Routing

| Stage | Role | Complexity | Risk | Model Profile | Inputs | Outputs | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- |
| spec | Spec Creator | standard | medium | {{MODEL_PROFILE}} | user request, project docs | spec.md | Capture requirements before planning |
| spec-review | Spec Reviewer | standard | high | high | spec.md | spec-review.md | Review ambiguity and acceptance criteria |
| plan | Plan Creator | standard | medium | {{MODEL_PROFILE}} | spec.md | plan.md | Translate requirements into implementation approach |
| plan-review | Plan Reviewer | standard | high | high | spec.md, plan.md | plan-review.md | Review feasibility, risks, and boundaries |
| tasks | Task Creator | standard | medium | {{MODEL_PROFILE}} | spec.md, plan.md | tasks.md | Split implementation into executable work |
| task-review | Task Reviewer | standard | high | high | spec.md, plan.md, tasks.md | task-review.md | Review task ownership and completeness |

## Dispatch Task Routing

| Task | Role | Complexity | Risk | Model Profile | Reason |
| --- | --- | --- | --- | --- | --- |
| T001 | API Designer | standard | medium | {{MODEL_PROFILE}} | Define contracts before implementation |
| T002 | Backend Implementer | standard | medium | {{MODEL_PROFILE}} | Backend behavior can affect data and API compatibility |
| T003 | Frontend Implementer | standard | low | {{MODEL_PROFILE}} | UI implementation follows approved plan |
| T004 | Mobile Implementer | standard | medium | {{MODEL_PROFILE}} | Mobile behavior may need device-specific care |
| T005 | Test Agent | standard | medium | {{MODEL_PROFILE}} | Test coverage must match acceptance criteria |
| T006 | Code Reviewer | standard | high | high | Review should use stronger reasoning than implementation |
| T007 | Fix Agent | standard | medium | {{MODEL_PROFILE}} | Fixes follow test/review findings |
| T008 | Commit Agent | trivial | low | low | Archive and summary work |

## Override Rules

- Use `extra-high` for auth, user, permission, payment, crypto, file upload,
  tenant isolation, security review, data migration, and public module reuse.
- Use `high` for major features, architecture, broad refactors, complex bug
  diagnosis, and code review.
- Use `medium` for standard backend, frontend, mobile, test, and integration
  tasks.
- Use `low` for docs-only, copy changes, small style changes, archive
  summaries, and low-risk mechanical edits.
- Human override wins when the user specifies a model profile for a feature or
  task.
