# Next-Stage Hardening Roadmap

This roadmap captures the next optimization stage after the `0.2.0` runtime
guardrails release.

The goal is not to add more concepts, roles, or templates. The goal is to make
the existing protocol harder to bypass:

> YAML should control generation and checks. Gates should block invalid stage
> transitions. Active context should reduce long-task context drift. State
> should be machine-readable, with Markdown rendered from it.

Priority order:

1. YAML-driven execution
2. Gate system hardening
3. Active context hardening
4. State-backed board rendering
5. Review isolation
6. Optional small engine extraction

## TODO 1: Make YAML Control Execution

### Goal

`agentflow.config.yml` must not be decorative. If a workflow piece is disabled
in config, the CLI must not generate it, check it, or block on it.

### Work Items

- [x] Load `agentflow.config.yml` from the project root.
- [x] Fall back to built-in defaults when config is missing.
- [x] Implement effective config merging:

```text
default config + user config = effective config
```

- [x] Make `create_feature` generate files from effective config.
- [x] Make `check` derive required files from effective config instead of a hardcoded file list.
- [x] If `gates.require_spec_review: false`, do not generate or require `spec-review.md`.
- [x] If `implementation.target_sides: [backend]`, generate and check only backend implementation outputs.
- [x] Document which config keys are runtime-enforced and which remain descriptive.

### Example

```yaml
gates:
  require_spec_review: false

implementation:
  target_sides:
    - backend
```

Expected behavior:

- no `spec-review.md`
- no spec review gate check
- no frontend/mobile result files
- no frontend/mobile check failures

## TODO 2: Split Check And Gate Semantics

### Goal

`check` should validate feature structure. `gate` should decide whether a stage
can advance.

### Proposed Commands

```sh
agentflow check FEATURE-001
agentflow gate spec FEATURE-001
agentflow gate plan FEATURE-001
agentflow gate tasks FEATURE-001
agentflow gate implement FEATURE-001
agentflow gate review FEATURE-001
agentflow gate archive FEATURE-001
```

Existing compatibility commands can stay, but docs should clearly explain the
canonical form.

### `check` Responsibilities

- [x] Feature directory exists.
- [x] Config-required files exist.
- [x] Obvious placeholders are removed.
- [x] File structure is internally complete.

### `gate` Responsibilities

- [x] Decide whether the current stage is allowed to advance.
- [x] Report the blocking reason in stable, agent-readable language.
- [x] Avoid mutating feature state unless explicitly requested.

### Gate Rules

#### spec gate

- [x] `spec.md` exists.
- [x] `spec.md` does not contain `TBD`.
- [x] Goal is explicit.
- [x] Scope is explicit.
- [x] Acceptance criteria exist.
- [x] If spec review is required, review metadata passes.

#### plan gate

- [x] `plan.md` exists.
- [x] `plan.md` does not contain `TBD`.
- [x] Implementation approach exists.
- [x] Impact file list exists.
- [x] Risk analysis exists.
- [x] If plan review is required, review metadata passes.

#### tasks gate

- [x] `tasks.md` exists.
- [x] `tasks.md` does not contain `TBD`.
- [x] At least one executable task exists.
- [x] Each task has an owner or execution role.
- [x] If task review is required, review metadata passes.

#### implement gate

- [x] Required implementation result files exist.
- [x] Test file exists when tests are required.
- [x] Test result is not pending.
- [x] Test result is not only "not tested".

#### review gate

- [x] Review file exists.
- [x] Review has a clear decision: `approved`, `rejected`, or `needs changes`.
- [x] Blocking issues prevent the gate from passing.

#### archive gate

- [x] `archive.md` exists.
- [x] Final result is summarized.
- [x] Change summary exists.
- [x] Test summary exists.
- [x] Remaining issues are documented.

## TODO 3: Harden Active Context

### Goal

Reduce long-task context drift by making active context the first file an agent
reads before work.

### Command

```sh
agentflow context FEATURE-001
```

### Output

Generate one or both:

```text
.agentflow/state/active_context.md
.agentflow/state/active_context.json
```

Status:

- [x] Generate `.agentflow/state/active_context.md`.
- [x] Continue generating `.agentflow/state/active_context.json`.

### Required Content

Keep active context short. It should include:

```text
Feature:
Current Stage:
Current Gate:
Goal:
Required Files:
Must Read:
Forbidden Actions:
Next Step:
Open Questions:
Related Code Files:
```

- [x] Include feature.
- [x] Include current stage.
- [x] Include current gate.
- [x] Include goal.
- [x] Include required files.
- [x] Include must-read files.
- [x] Include forbidden actions.
- [x] Include next step.
- [x] Include open questions.
- [x] Include related code files.

### Required Header

```text
This is the current working contract.
Start from this file before doing any work.
Do not start coding before checking the current gate.
Only open additional docs/files when this context references them or the current task requires verification.
```

- [x] Add required active context header.

Active context is the current task entry point, not the only source of truth.
Agents should read it first, then open referenced docs and code as needed.

## TODO 4: State-Backed Board Rendering

### Problem

Directly appending rows to `project-docs/03_TASK_BOARD.md` makes the task board
a fragile data source:

- Markdown tables can break.
- Git conflicts are likely.
- Runtime state is hard to parse reliably.

### Goal

State is the source data. Markdown is a rendered view.

### State File

```text
.agentflow/state/features.yml
```

Example:

```yaml
features:
  - id: FEATURE-001
    title: User Auth
    stage: plan
    status: pending
    owner: Manager
    updated_at: 2026-05-27
```

### Command

```sh
agentflow board render
```

Responsibilities:

- [x] Read `.agentflow/state/features.yml`.
- [x] Regenerate `project-docs/03_TASK_BOARD.md`.
- [x] Treat Markdown as output, not canonical state.

## TODO 5: Review Isolation

### Goal

Prevent self-review from silently approving high-risk stages.

This does not require a full multi-agent runtime yet. Start with protocol-level
metadata and gate checks.

### Config Shape

```yaml
review:
  spec:
    mode: separate-session
  plan:
    mode: self
  tasks:
    mode: self
  implementation:
    mode: human
```

Supported modes:

- `self`
- `separate-session`
- `human`

### `self`

The current AI may review its own work. Gate should mark this as weak review.
Use for low-risk stages only.

### `separate-session`

Review must be performed in a separate AI session. The review file must include
metadata:

```yaml
review_mode: separate-session
reviewer: external
decision: approved
blocking_issues: 0
reviewed_at: 2026-05-27
```

If metadata is missing or invalid, the gate must fail.

- [x] `review.mode` is read from config.
- [x] `separate-session` review metadata is checked by gates.

### `human`

Human approval is required. Do not allow the AI to hand-write human sign-off.

Command:

```sh
agentflow approve FEATURE-001 --stage spec
```

The command writes approval metadata:

```yaml
approved_by: local-user
approved_at: 2026-05-27T12:00:00
approval_source: cli
```

The gate checks this metadata.

- [x] `agentflow approve FEATURE --stage <stage>` writes CLI approval metadata.
- [x] `human` review mode requires CLI approval metadata.

## TODO 6: Do Not Do Yet

- Do not add more roles.
- Do not add more complex templates.
- Do not build a full runtime platform.
- Do not auto-spawn multiple agents.
- Do not add a database.
- Do not turn YAML into a complex DSL.
- Do not weaken the core workflow for small tasks.
- Do not immediately rewrite everything in Node or Python.

## TODO 7: Technical Implementation Route

Keep `bin/agentflow` as the CLI entrypoint for now.

When logic becomes too complex for shell, gradually extract a small engine.

Possible Node structure:

```text
lang-agentflow-kit/
  bin/
    agentflow
  engine/
    config.js
    gate.js
    context.js
    board.js
```

Possible Python structure:

```text
lang-agentflow-kit/
  bin/
    agentflow
  agentflow_engine/
    config.py
    gate.py
    context.py
    board.py
```

Do not copy engine code into each user's `.agentflow/engine/` directory.

User projects should keep only project-local state and configuration:

```text
.agentflow/
  config.yml
  state/
```

Tool code should upgrade with `lang-agentflow-kit` itself.

## Recommended Version Route

The current released version is `0.2.0`, so the original external suggestion of
"v0.2: YAML truly controls execution" is re-mapped to the next patch/minor
sequence.

### v0.2.x: YAML Truly Controls Execution

- [x] Read config.
- [x] Merge default config.
- [x] Generate feature files from effective config.
- [x] Check files from effective config.

### v0.3: Gate System Hardening

- [x] Split `check` and `gate` semantics.
- [x] Add stage-specific gate commands.
- [x] Ensure each gate checks whether the stage can advance.

### v0.4: Active Context Hardening

- [x] Generate stronger active context.
- [x] Include current working contract header.
- [x] Reduce long-task context drift.

### v0.5: State + Board Render

- [x] Add `.agentflow/state/features.yml`.
- [x] Add `agentflow board render`.
- [x] Render Markdown board from state.

### v0.6: Review Isolation

- [x] Support `review.mode`.
- [x] Support `separate-session` metadata.
- [x] Support `agentflow approve`.

## Final Principle

Lang AgentFlow Kit is not for tiny changes that can be handled by direct
coding. Its value is stable protocol, stage gates, context control, and
execution order for complex, long-context, multi-stage, multi-agent projects.

Do not keep piling on concepts. Make the existing protocol hard enough that an
agent cannot skip the workflow and still pass the gate.
