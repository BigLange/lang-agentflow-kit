# AgentFlow Config Schema

This document describes the current `agentflow.config.yml` shape used by
Lang AgentFlow Kit.

It intentionally separates:

- keys that are actively read by the current CLI runtime
- keys that are descriptive metadata or adapter-facing configuration

The current runtime is lightweight and does **not** implement a full YAML
schema engine. Keep configs simple.

## Example

```yaml
version: 1
profile: standard
complexity_profile: standard

project:
  feature_dir: features
  docs_dir: project-docs

runtime:
  state_dir: .agentflow/state
  active_context_file: active_context.json
  enforce_dispatch_gate: true
  enforce_archive_gate: true
  hook_failure_policy: stop

hooks:
  before_dispatch:
    - bin/agentflow feature status {{FEATURE}}
  after_plan:
    - bin/agentflow feature context {{FEATURE}}
  after_implement:
    - bin/agentflow feature verify {{FEATURE}} --stage implement

gates:
  require_spec_review: true
  require_plan_review: true
  require_task_review: true
  require_dispatch_record_for_archive: true
  require_summary_records_for_done: true
  require_tests_before_done: true
  require_review_before_commit: true
```

## Runtime-Read Keys

These keys are read by the current `bin/agentflow` runtime.

### Top Level

- `version`
  Used as config metadata only. Current templates set it to `1`.
- `profile`
  Profile metadata such as `lite`, `standard`, or `full`.
- `complexity_profile`
  Human-facing label such as `light`, `standard`, or `strict`.

### `project`

- `project.feature_dir`
  Default: `features`
  Used to resolve feature bundle directories.
- `project.docs_dir`
  Default: `project-docs`
  Used to resolve records, task board, and project docs.

### `runtime`

- `runtime.state_dir`
  Default: `.agentflow/state`
  Output directory for generated runtime state such as `active_context.json`.
- `runtime.active_context_file`
  Default: `active_context.json`
  File name written by `agentflow feature context`.
- `runtime.enforce_dispatch_gate`
  Default: `true`
  If true, `feature dispatch` hard-checks the `dispatch` gate first.
- `runtime.enforce_archive_gate`
  Default: `true`
  If true, `feature archive` hard-checks the `archive` gate first.
- `runtime.hook_failure_policy`
  Default: `stop`
  Controls hook failure behavior.
  Supported values:
  - `stop`: fail immediately when a hook command exits non-zero
  - `warn`: print a warning and continue

### `hooks`

Supported hook keys:

- `hooks.before_plan`
- `hooks.before_tasks`
- `hooks.before_dispatch`
- `hooks.before_implement`
- `hooks.before_test`
- `hooks.before_review`
- `hooks.before_fix`
- `hooks.before_archive`
- `hooks.after_spec`
- `hooks.after_plan`
- `hooks.after_tasks`
- `hooks.after_dispatch`
- `hooks.after_implement`
- `hooks.after_test`
- `hooks.after_review`
- `hooks.after_fix`

Each hook value should be a simple YAML list of shell command strings.

Hook timing:

- `before_<stage>` runs before the runtime checks entry into that target stage
- `after_<stage>` runs after the previous stage has successfully completed

Examples:

- `feature gate FEATURE-001-demo --to tasks` may trigger `before_tasks` and then `after_plan`
- `feature advance FEATURE-001-demo --to review` may trigger `before_review` and then `after_test`

Supported token expansion inside hook commands:

- `{{FEATURE}}`
- `{{FEATURE_DIR}}`
- `{{PROJECT_ROOT}}`
- `{{STAGE}}`

### `gates`

Current `gates:` keys are intentionally global booleans. They keep the v1
runtime simple and easy to parse from shell.

- `gates.require_spec_review`
  If true, `spec-review.md` must pass before `spec` is considered valid.
- `gates.require_plan_review`
  If true, `plan-review.md` must pass before `plan` is considered valid.
- `gates.require_task_review`
  If true, `task-review.md` must pass before `tasks` is considered valid.
- `gates.require_dispatch_record_for_archive`
  If true, `archive` requires a valid dispatch record.
- `gates.require_summary_records_for_done`
  If true, `done` requires valid review/test/done summary records.
- `gates.require_tests_before_done`
  If true, `implementation/test.md` must pass before later stages can pass.
- `gates.require_review_before_commit`
  If true, `implementation/review.md` must pass before later stages can pass.
- `gates.require_archive_before_done`
  Currently descriptive in templates. The runtime already models `done` as
  strictly after `archive`, so this key is effectively redundant today.

Future versions may replace or supplement the global booleans with per-stage
structured rules:

```yaml
stages:
  plan:
    requires:
      - spec
    outputs:
      - plan.md
      - plan-review.md
  archive:
    requires:
      - fix
      - test
      - review
    records:
      - dispatch
```

The example above is a design direction, not a format consumed by the current
runtime.

## Metadata / Adapter Keys

These keys are present in templates and useful for humans or future adapters,
but the current local runtime does not rely on them heavily.

### `spec`

Examples:

- `spec.provider`
- `spec.source_dir`
- `spec.required_outputs`

Current usage:

- `spec.required_outputs` is descriptive only in the local runtime.
- The CLI still uses hardcoded stage file names for validation.

### `orchestrator`

Examples:

- `orchestrator.provider`
- `orchestrator.mode`
- `orchestrator.fallback_provider`
- `orchestrator.default_mode`
- `orchestrator.long_task_default`

Current usage:

- Mostly descriptive.
- Useful for adapter intent and README alignment.

### `skills`

Examples:

- `skills.provider`
- `skills.vendored_superpowers`
- `skills.role_method_map.*`

Current usage:

- Descriptive only in the local runtime.
- The init flow still copies vendored skills based on selected profile.

### `integrations`

Examples:

- `integrations.spec_kit.*`
- `integrations.oh_my_codex.*`

Current usage:

- Primarily adapter metadata and template configuration.
- Not directly executed by the local runtime.

### `archive`

Examples:

- `archive.provider`
- `archive.records_dir`
- `archive.task_board`
- `archive.subagent_dir`

Current usage:

- These values are descriptive today.
- The runtime resolves paths through `project.docs_dir` and built-in conventions.

## Stage Model

The current runtime stage sequence is:

```text
draft
-> spec
-> plan
-> tasks
-> dispatch
-> implement
-> test
-> review
-> fix
-> archive
-> done
```

Important distinction:

- `archive` means the feature bundle itself is complete
- `done` means project-level summary records are also complete

Stage checks are currently encoded by `bin/agentflow`:

| Stage | Runtime Check |
| --- | --- |
| `spec` | `spec.md` exists, has no placeholders, and `spec-review.md` passes when required |
| `plan` | `spec` passes, `plan.md` has no placeholders, and `plan-review.md` passes when required |
| `tasks` | `plan` passes, `tasks.md` contains delivery tasks, and `task-review.md` passes when required |
| `dispatch` | `tasks` passes and `dispatch.md` has role assignment rows |
| `implement` | `dispatch` passes and implementation result records are complete |
| `test` | `implement` passes and `implementation/test.md` is complete when required |
| `review` | `test` passes and `implementation/review.md` is complete when required |
| `fix` | `review` passes and `results/fix.md` is complete |
| `archive` | `fix` passes, dispatch record policy passes, and `archive.md` is complete |
| `done` | `archive` passes and review/test/done summary records are complete when required |

For agents and scripts, CLI output is the source of truth for current feature
state. Do not infer stage status from the task board alone.

## Output Examples

Blocked status example:

```text
Feature: FEATURE-001-demo
Current Stage: draft
Next Gate: plan
Progress: 0%
Gate Status: blocked before plan
Top Blockers:
  - spec.md still contains placeholders
  - spec-review.md status is still pending
```

Passing gate example:

```text
Gate passed: FEATURE-001-demo can enter plan
```

Generated context example:

```json
{
  "feature": "FEATURE-001-demo",
  "current_stage": "spec",
  "next_gate": "tasks",
  "open_tasks": [],
  "key_files": []
}
```

## Records Policy

Recommended default:

- durable and versioned: feature specs, plans, tasks, test summaries, review
  summaries, fix summaries, archives, and done records
- generated and ignored: `.agentflow/state/`
- transient by default: `project-docs/records/dispatch/`

Projects that require full audit trails can remove
`project-docs/records/dispatch/` from `.gitignore` and treat dispatch records as
durable history.

## Template Task Sync Model

`agentflow feature sync` only updates the standard generated tasks:

- `T001` API/contracts
- `T002-T004` implementation
- `T005` test
- `T006` review
- `T007` fix
- `T008-T009` completion/archive

Custom task rows are left untouched.

## Parser Constraints

The current config reader is intentionally lightweight.

Safe patterns:

- simple top-level scalars
- two-level nested keys like `project.feature_dir`
- hook lists under `hooks.before_<stage>` and `hooks.after_<stage>`

Avoid for now:

- deeply nested custom structures
- anchors or advanced YAML features
- multiline values that need precise parsing

## Recommended Defaults

For most long-running projects:

- `profile: standard`
- `complexity_profile: standard`
- all review/test/done gates enabled
- runtime state ignored by Git
- dispatch records ignored by Git unless the project explicitly wants them

## Migration Notes

For existing Markdown-only projects:

1. Add or update `agentflow.config.yml`.
2. Point `project.feature_dir` and `project.docs_dir` at the existing layout.
3. Ensure the active feature has the standard bundle files.
4. Run `agentflow feature status FEATURE-XXX-*`.
5. Fix the earliest blocker reported by the runtime.
6. Repeat `agentflow feature next FEATURE-XXX-*` until the feature reaches
   `archive` or `done`.

Migration is incremental. Start with the active feature rather than rewriting
all historical work.

## Related Docs

- [README.md](../README.md)
- [runtime-guardrails-todo.md](./runtime-guardrails-todo.md)
