# Lang AgentFlow Kit Internals

See the root `README.md` for installation, profile comparison, workflow
description, subagent counts, Superpowers mappings, and Oh My Codex adapter
guidance.

## Architecture Summary

Lang AgentFlow Kit combines four layers:

- spec-kit style specification artifacts: `spec.md`, `plan.md`, `tasks.md`
- subagent-first implementation orchestration for long tasks
- Superpowers-style role methods for planning, review, testing, and fixing
- project records for dispatch, completion, review, and archive

The stable contract is the Feature Bundle under `features/FEATURE-XXX-*`.
Providers can change as long as they read and write the bundle plus
`project-docs/records/`.
