# Dispatch: {{FEATURE_TITLE}}

## Strategy

Mode: subagent-first

Manager reads `spec.md`, `plan.md`, `tasks.md`, and review gates. Each worker
receives only the relevant bundle files and target paths.

## Role Assignments

| Task | Role | Model Profile | Inputs | Outputs | Status |
| --- | --- | --- | --- | --- | --- |
| API design | API Designer | {{MODEL_PROFILE}} | spec.md, plan.md, model-routing.md | implementation/api.md | pending |
| Backend | Backend Implementer | {{MODEL_PROFILE}} | plan.md, implementation/api.md, model-routing.md | code + results/backend.md | pending |
| Frontend | Frontend Implementer | {{MODEL_PROFILE}} | plan.md, implementation/api.md, model-routing.md | code + results/frontend.md | pending |
| Mobile | Mobile Implementer | {{MODEL_PROFILE}} | plan.md, implementation/api.md, model-routing.md | code + results/mobile.md | optional |
| Tests | Test Agent | {{MODEL_PROFILE}} | spec.md, tasks.md, changed files, model-routing.md | implementation/test.md | pending |
| Review | Code Reviewer | high | spec.md, plan.md, diff, model-routing.md | implementation/review.md | pending |
| Fix | Fix Agent | {{MODEL_PROFILE}} | review/test findings, model-routing.md | code + results/fix.md | pending |
| Commit | Commit Agent | low | final diff, test output | archive.md | pending |

## Persistent Records

Each dispatched subagent should produce a record under `project-docs/records/`
or the feature bundle `results/` directory. Do not use inbox/outbox messaging.
