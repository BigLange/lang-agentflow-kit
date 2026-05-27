# Dispatch: 支付/退款 & 对账

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

## CCB Fallback

If runtime subagents are unavailable, convert each row into a CCB `/ask` file
under `project-docs/ccb/inbox/`.
