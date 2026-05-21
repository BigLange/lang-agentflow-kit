# Dispatch: {{FEATURE_TITLE}}

## Strategy

Mode: subagent-first

Manager reads `spec.md`, `plan.md`, `tasks.md`, and review gates. Each worker
receives only the relevant bundle files and target paths.

## Role Assignments

| Task | Role | Inputs | Outputs | Status |
| --- | --- | --- | --- | --- |
| API design | API Designer | spec.md, plan.md | implementation/api.md | pending |
| Backend | Backend Implementer | plan.md, implementation/api.md | code + results/backend.md | pending |
| Frontend | Frontend Implementer | plan.md, implementation/api.md | code + results/frontend.md | pending |
| Mobile | Mobile Implementer | plan.md, implementation/api.md | code + results/mobile.md | optional |
| Tests | Test Agent | spec.md, tasks.md, changed files | results/test.md | pending |
| Review | Code Reviewer | spec.md, plan.md, diff | implementation/review.md | pending |
| Fix | Fix Agent | review/test findings | code + results/fix.md | pending |
| Commit | Commit Agent | final diff, test output | archive.md | pending |

## Persistent Records

Each dispatched subagent should produce a record under `project-docs/records/`
or the feature bundle `results/` directory. Do not use inbox/outbox messaging.
