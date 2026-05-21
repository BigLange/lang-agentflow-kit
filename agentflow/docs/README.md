# Lang AgentFlow Kit

Lang AgentFlow Kit combines four layers:

- spec-kit style specification artifacts: `spec.md`, `plan.md`, `tasks.md`
- subagent-first implementation orchestration for long tasks
- Superpowers-style role methods for planning, review, testing, and fixing
- project records for dispatch, completion, review, and archive, inspired by
  the previous CCB record discipline but without inbox/outbox communication

The integration is intentionally adapter based. The stable contract is the
Feature Bundle under `features/FEATURE-XXX-*`; providers can change as long as
they read and write the bundle.

## Commands

```sh
npm link
agentflow init --profile standard
./install.sh /path/to/project --profile lite
./install.sh /path/to/project --profile standard
./install.sh /path/to/project --profile full
bin/agentflow init --profile standard
bin/agentflow feature "Build user login"
bin/agentflow check FEATURE-001-build-user-login
bin/agentflow dispatch FEATURE-001-build-user-login
bin/agentflow archive FEATURE-001-build-user-login
```

## Profiles

- `lite`: AgentFlow core only. Minimal gates, no vendored Superpowers skills,
  no Oh My Codex adapter.
- `standard`: AgentFlow core plus project-local Superpowers-style skills.
  Uses Codex subagents as the runtime path.
- `full`: Standard profile plus Oh My Codex adapter config under
  `.agentflow/integrations/oh-my-codex.yml`.

Oh My Codex is treated as a replaceable orchestrator adapter. The stable
contract is still the Feature Bundle, so another orchestrator can replace it by
consuming `dispatch.md` and writing records under `project-docs/records/`.

## Feature Bundle

```text
features/FEATURE-XXX-name/
├── spec.md
├── spec-review.md
├── plan.md
├── plan-review.md
├── tasks.md
├── task-review.md
├── dispatch.md
├── implementation/
│   ├── api.md
│   ├── backend.md
│   ├── frontend.md
│   ├── mobile.md
│   ├── test.md
│   └── review.md
├── results/
└── archive.md
```

## Role Model

Manager owns state, gates, dispatch, and archive. Creator/reviewer roles are
split so each major artifact has an independent check before the next phase.
Implementation roles receive narrow context from the Feature Bundle. Runtime
collaboration is subagent-only; persistent records are written under
`project-docs/records/`.
