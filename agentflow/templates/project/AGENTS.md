# Project Agent Rules

This project uses Lang AgentFlow Kit. This file is the project-level rule layer:
it defines roles, boundaries, workflow order, and record expectations. It does
not replace detailed role prompts in `.agentflow/agents/` or skills in
`.agentflow/skills/`.

## 1. Operating Model

The default runtime model is subagent-only.

- The main assistant acts as Manager / Orchestrator.
- New sessions should start from `project-docs/ACTIVE_WORK.md` when it exists.
  The user should be able to say: "You are the Manager; continue development."
  Treat that as shorthand for reading `AGENTS.md`, `agentflow.config.yml`, and
  `project-docs/ACTIVE_WORK.md` before continuing.
- Long or multi-stage work should be delegated to fresh subagents with narrow
  context.
- CCB-style inbox/outbox messaging is not used. Persistent records are written
  under `project-docs/records/` and feature bundle `results/` directories.
- Use `agentflow feature context FEATURE-XXX-*` to refresh the active runtime
  context before long multi-step work.
- Use `agentflow feature status FEATURE-XXX-*` before stage handoff. CLI output
  is the source of truth for runtime stage state.
- The Manager should run or verify routine checks through hooks and CLI
  commands. The human supervises the Manager's reported checks instead of
  manually driving every gate.
- Creator and reviewer roles are separated for spec, plan, tasks, implementation
  review, and final verification.

## 2. First Step After Init

After `agentflow init`, do not start by creating a feature unless the user is
adding one feature to an existing project.

For a new project, first complete the project-level documents:

- `project-docs/00_PROJECT_CONTEXT.md`
- `project-docs/01_ARCHITECTURE.md`
- `project-docs/02_API_SPEC.md`
- `project-docs/03_TASK_BOARD.md`

If `00_PROJECT_CONTEXT.md` or `01_ARCHITECTURE.md` contains `TBD`, the Manager
must clarify or draft those documents before implementation work begins.

## 3. Role Families

### Manager / Orchestrator

- Owns project state, gates, dispatch, records, and final archive.
- Owns `project-docs/ACTIVE_WORK.md` as the cross-session resume point.
- Reads project docs and current feature bundle before delegating.
- Uses CLI stage gates instead of relying on memory alone for stage transitions.
- Keeps the main context focused on decisions and state, not implementation
  details.
- Does not let multiple subagents edit the same unclear scope at the same time.
- Ends each work session with the configured heartbeat output and updates
  `project-docs/ACTIVE_WORK.md`.

### Specification Roles

- `Spec Creator`: turns user intent into clear project or feature requirements.
- `Spec Reviewer`: checks scope, acceptance criteria, ambiguity, and testability.

### Planning Roles

- `Plan Creator`: defines architecture, contracts, data model, risks, and
  validation strategy.
- `Plan Reviewer`: checks feasibility, boundaries, dependencies, and missing
  decisions.
- `Task Creator`: creates delivery-oriented tasks covering API, implementation,
  tests, review, fixes, and archive.
- `Task Reviewer`: checks that tasks are executable, owned, and independently
  verifiable.

### Implementation Roles

- `API Designer`: stabilizes contracts before backend/frontend/mobile work.
- `Backend Implementer`: owns backend code and server-side integration.
- `Frontend Implementer`: owns web UI, state, and API consumption.
- `Mobile Implementer`: owns mobile implementation when the project has mobile
  surfaces.

### Quality Roles

- `Test Agent`: writes or runs tests and records verification.
- `Code Reviewer`: reviews final diffs for bugs, regressions, API drift,
  security, and maintainability.
- `Fix Agent`: fixes only review or test findings.
- `Commit Agent`: prepares final archive and commit summary.

## 4. Workflow

For a new project:

1. Complete project context.
2. Complete architecture and API boundaries.
3. Create milestones and initial task board.
4. Split work into features only after the project-level plan is clear.

For a feature:

1. Create or update `features/FEATURE-XXX-*/spec.md`.
2. Review the spec.
3. Run `agentflow feature status FEATURE-XXX-*` and resolve reported blockers.
4. Create or update `plan.md`.
5. Review the plan.
6. Create or update `tasks.md`.
7. Review tasks.
8. Dispatch subagents using `dispatch.md`.
9. Run implementation, test, review, fix, and archive.

## 5. Directory Boundaries

- Root `AGENTS.md`: project rule layer.
- `.agentflow/agents/`: role contracts.
- `.agentflow/skills/`: project-local methods, present in standard/full
  profiles.
- `.agentflow/integrations/`: optional runtime adapters, such as Oh My Codex in
  full profile.
- `project-docs/`: project-level context, architecture, API, board, and records.
- `features/`: feature-level spec, plan, tasks, dispatch, results, and archive.

## 6. Records

Every meaningful handoff or completion should leave a concise record:

- dispatch records: `project-docs/records/dispatch/`
- done records: `project-docs/records/done/`
- review records: `project-docs/records/review/`
- test records: `project-docs/records/test/`
- feature archives: `features/FEATURE-XXX-*/archive.md`

Recommended Git policy:

- keep durable project knowledge in Git: specs, plans, tasks, review summaries,
  test summaries, done summaries, archives
- treat `.agentflow/state/` as generated runtime state
- treat `project-docs/records/dispatch/` as transient dispatch logs unless the
  project explicitly wants them versioned

Records should include inputs, outputs, changed files, verification, risks, and
next action.

## 7. Guardrails

- Read existing files before editing.
- Preserve unrelated user changes.
- Prefer existing project patterns over new abstractions.
- Define API contracts before parallel frontend/backend/mobile work.
- Do not implement from vague requirements; clarify or document assumptions.
- Keep subagent prompts narrow and self-contained.
- If a task is blocked, record the blocker and required decision.
- If the configured heartbeat output is missing from the previous Manager
  output or `ACTIVE_WORK.md`, re-read this file,
  `agentflow.config.yml`, and `project-docs/ACTIVE_WORK.md` before continuing.

## 8. Cross-Session Resume

The durable resume file is:

```text
project-docs/ACTIVE_WORK.md
```

At the start of a new session, the Manager must:

1. Read `AGENTS.md`.
2. Read `project-docs/ACTIVE_WORK.md`.
3. Run `agentflow feature status FEATURE-XXX-*` for the current feature when one
   is listed.
4. Continue the recorded next action instead of re-planning from scratch.

At the end of a session, the Manager must update `ACTIVE_WORK.md` with:

- current feature
- current stage
- current task
- owner role
- task status across backend/frontend/mobile/test/review when relevant
- checks actually run
- blockers
- next action
- whether human input is needed

The final response must include the configured heartbeat. Default compact
format:

```text
AI为你保驾护航 | checks: yes/no | active_work: yes/no | next: short next action | human: yes/no
```

When `manager.heartbeat_mode: full`, use:

```yaml
heartbeat_phrase: AI为你保驾护航
anchor_pulse:
  current_feature: FEATURE-XXX or none
  current_stage: stage or none
  current_task: task id or none
  checks_run: yes/no
  active_work_updated: yes/no
  next_action_clear: yes/no
  human_needed: yes/no
```
