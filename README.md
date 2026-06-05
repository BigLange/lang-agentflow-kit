# Lang AgentFlow Kit

Current version: `0.6.0`

Lang AgentFlow Kit is a local workflow initializer for AI-assisted software
projects. It creates a subagent-first project structure, Markdown working
contracts, and lightweight CLI guardrails so long-running AI collaboration has
clear state, handoff points, and review checkpoints.

It is designed for complex projects where agents, humans, specs, plans, tasks,
tests, reviews, and archive records need to stay aligned over time.

## What It Is

Lang AgentFlow Kit is:

- a local project workflow initializer
- a Markdown protocol for AI-assisted development
- a lightweight CLI guardrail system
- a subagent-first collaboration structure

## What It Is Not

It is not:

- an automatic agent runner
- a background daemon
- a full multi-agent orchestration platform
- a replacement for Codex / Claude Code / Gemini CLI
- a tool mainly designed for tiny one-line changes

## What Problem It Solves

AI-assisted projects often drift when work spans many sessions: specs stay
unfinished, plans and tasks diverge, reviews are skipped, task boards are edited
by hand, and later agents do not know what state the project is really in.

AgentFlow gives the project a small local contract:

- `AGENTS.md` tells agents how to work in this repo.
- `project-docs/` stores project context, architecture notes, API notes, and the task board.
- `features/FEATURE-XXX-*` stores feature-level specs, plans, tasks, results, and archive notes.
- `agentflow` CLI checks gates, writes active context, renders the board, and reports status.

## Who It Is For

| Good Fit | Poor Fit |
| --- | --- |
| Long-running AI-assisted projects | One-line edits |
| Personal projects or small teams using AI heavily | Throwaway experiments |
| Work that needs specs, plans, tests, reviews, and handoffs | Scripts with no lifecycle |
| Projects where multiple agents/sessions may touch the same feature | Fully automated agent platforms |

## Platform Support

| Platform | Support |
| --- | --- |
| macOS | Supported |
| Linux | Supported |
| Windows | Use WSL or Git Bash |
| Native PowerShell | Not fully supported yet |

Notes:

- npm is used mainly for installation and distribution.
- Node `>=18` is the package installation requirement.
- The current runtime is still a Bash CLI.

## Installation

Install from GitHub:

```sh
npm install -g github:BigLange/lang-agentflow-kit
```

Check the installed version:

```sh
agentflow --version
agentflow version
```

Run from a source checkout:

```sh
/path/to/lang-agentflow-kit/bin/agentflow --version
```

## 5-Minute Quick Start

```sh
npm install -g github:BigLange/lang-agentflow-kit

mkdir demo-agentflow
cd demo-agentflow

agentflow init --profile standard
agentflow feature create "customer export"
agentflow feature status FEATURE-001-customer-export
agentflow feature next FEATURE-001-customer-export
```

What happens:

| Step | What It Does |
| --- | --- |
| `agentflow init --profile standard` | Creates `AGENTS.md`, `agentflow.config.yml`, `.agentflow/`, `project-docs/`, and `features/`. |
| `agentflow feature create "customer export"` | Creates `features/FEATURE-001-customer-export/` with the feature bundle and `state.yml`. |
| `agentflow feature status FEATURE-001-customer-export` | Shows the current stage, next gate, task progress, records, and blockers. |
| `agentflow feature next FEATURE-001-customer-export` | Attempts to advance to the next stage. If blocked, it prints which files need work. |

If a gate blocks, that is expected. Open the files it reports, fill the missing
spec/plan/task/test/review content, then run `status`, `gate`, or `next` again.

## Generated Files

`project-docs/03_TASK_BOARD.md` is generated. Do not edit it directly.

Use these commands instead:

```sh
agentflow feature next FEATURE-001-customer-export
agentflow feature status FEATURE-001-customer-export
agentflow board render
```

Generated task boards include a header like:

```md
<!--
GENERATED FILE: DO NOT EDIT DIRECTLY.
-->
```

The source of truth for feature progress is:

```text
features/FEATURE-XXX/state.yml
```

## Common Commands

| Command | Purpose |
| --- | --- |
| `agentflow init --profile standard` | Initialize AgentFlow in the current project. |
| `agentflow feature create "user auth"` | Create a new feature bundle. |
| `agentflow feature create "fix login text" --type trivial` | Create a smaller workflow for a trivial change. |
| `agentflow feature status FEATURE-001-user-auth` | Inspect feature state and next gate. |
| `agentflow feature next FEATURE-001-user-auth` | Try to advance through the next workflow step. |
| `agentflow gate spec FEATURE-001-user-auth` | Check a stage without mutating state. |
| `agentflow feature context FEATURE-001-user-auth` | Generate active context for agent handoff. |
| `agentflow check --all` | Run project-level health checks suitable for CI. |
| `agentflow check FEATURE-001-user-auth` | Strictly check one feature for missing files/placeholders. |
| `agentflow doctor` | Check local runtime health. |
| `agentflow board render --check` | Verify the generated task board is fresh. |
| `agentflow module list` | List registered external/internal modules. |
| `agentflow module contract MODULE_ID` | Generate local contract and notes templates for a module. |
| `agentflow reuse analyze FEATURE-001-user-auth` | Generate feature-level reuse analysis. |
| `agentflow reuse gate FEATURE-001-user-auth` | Check external module reuse policy before implementation. |

## Init Profiles

| Profile | Includes | Best For | Pros | Cons |
| --- | --- | --- | --- | --- |
| `lite` | Core files, `AGENTS.md`, project docs, feature templates, records, lighter runtime | Projects that want the minimum protocol layer | Small and easy to adopt | Less process guidance |
| `standard` | Everything in `lite` plus vendored Superpowers-style skills | Most long-running AI-assisted projects | Best default balance | More structure than tiny tasks need |
| `full` | Everything in `standard` plus optional Oh My Codex adapter config | Projects preparing external orchestration integration | Most complete template | Heavier; not an automatic orchestrator |

Recommended default:

```sh
agentflow init --profile standard
```

## Feature Types

| Type | Stages |
| --- | --- |
| `trivial` | `implement`, `archive` |
| `bug` | `implement`, `test`, `archive` |
| `standard` | `spec`, `plan`, `tasks`, `implement`, `test`, `archive` |
| `major` | `spec`, `plan`, `tasks`, `dispatch`, `implement`, `test`, `review`, `fix`, `archive` |
| `sensitive` | `spec`, `reuse-risk`, `plan`, `tasks`, `dispatch`, `implement`, `security-review`, `test`, `review`, `fix`, `archive` |

Use smaller types for small work so the process does not become token-heavy.
Use `major` or `sensitive` when correctness, security, permissions, payments,
or external reuse risk matters.

## External Module Governance

AgentFlow can register and gate external modules without downloading or copying
their code. Public modules are not trusted by default, and sensitive domains
such as auth, user, permission, payment, crypto, file upload, admin accounts,
and tenant isolation are treated as high risk.

Typical flow:

```sh
agentflow module add public-admin-template \
  --name "Public Admin Template" \
  --source-type public \
  --source github:example/admin-template \
  --module-type template \
  --domain admin \
  --risk high \
  --mode reference-only

agentflow module contract public-admin-template
agentflow reuse analyze FEATURE-001-admin-user-permission
agentflow reuse gate FEATURE-001-admin-user-permission
```

Generated governance files:

```text
.agentflow/modules/external_modules.yml
.agentflow/modules/external_module_policy.yml
.agentflow/modules/MODULE_ID/module-contract.yml
.agentflow/modules/MODULE_ID/security-notes.md
.agentflow/modules/MODULE_ID/integration-notes.md
features/FEATURE-XXX/reuse-analysis.md
features/FEATURE-XXX/external-module-risk.md
```

Safety boundaries:

- AgentFlow does not download public repositories.
- AgentFlow does not copy or vendor public code automatically.
- Public critical-domain modules are reference-only by default.
- Public `direct-copy` is blocked.
- Public high/critical `vendor` requires explicit human approval.

## Core Outputs

Typical initialized project:

```text
AGENTS.md
agentflow.config.yml
.agentflow/
  modules/
    external_modules.yml
    external_module_policy.yml
project-docs/
  00_PROJECT_CONTEXT.md
  01_ARCHITECTURE.md
  02_API_SPEC.md
  03_TASK_BOARD.md
features/
  FEATURE-001-customer-export/
    state.yml
    spec.md
    plan.md
    tasks.md
    implementation/
    results/
    archive.md
```

<details>
<summary>Example active_context.md</summary>

```md
# Active Context

Current Feature: FEATURE-001-customer-export
Current Stage: plan
Next Gate: tasks

Must Read:
- AGENTS.md
- features/FEATURE-001-customer-export/spec.md
- features/FEATURE-001-customer-export/plan.md

Do Not:
- edit generated files directly
- skip gate checks
```

</details>

<details>
<summary>Example feature state.yml</summary>

```yaml
id: "FEATURE-001-customer-export"
title: "customer export"
type: "standard"
stage: "draft"
status: "pending"
mode: "subagent"
owner: "Manager"
verified: "no"
notes: "Created by agentflow feature create"
updated_at: "2026-06-05"
```

</details>

## What It Can Do Today

- Initialize a local AgentFlow project structure.
- Generate feature bundles from templates.
- Maintain per-feature state in `features/FEATURE-XXX/state.yml`.
- Render `project-docs/03_TASK_BOARD.md` from feature state.
- Check feature gates and report blockers.
- Generate active context for agent handoff.
- Run local health checks with `agentflow doctor`.
- Generate warning-mode Git hooks and GitHub Actions templates.
- Generate basic Cursor / Cline / Codex rule files.

## Current Limitations

- It is not an automatic Agent runner.
- It cannot truly spawn subagents by itself.
- Git hooks / CI enforcement are currently lightweight and warning-first.
- Legacy global state, if present, is cache/index data only; feature state lives
  in `features/FEATURE-XXX/state.yml`.
- External public module reuse is governance-only; do not auto-copy public auth,
  permission, payment, upload, crypto, or admin-account modules into a project.
- Native Windows PowerShell support is limited; use WSL or Git Bash.
- The runtime is intentionally Bash-based and deterministic, not a full YAML
  schema engine.

## Detailed Docs

| Topic | Link |
| --- | --- |
| Product introduction | [`docs/lang-agentflow-kit-introduction.md`](docs/lang-agentflow-kit-introduction.md) |
| Config schema | [`docs/config-schema.md`](docs/config-schema.md) |
| Runtime guardrails TODO | [`docs/runtime-guardrails-todo.md`](docs/runtime-guardrails-todo.md) |
| Hardening roadmap | [`docs/next-stage-hardening-roadmap.md`](docs/next-stage-hardening-roadmap.md) |
| Changelog | [`CHANGELOG.md`](CHANGELOG.md) |

## Development

```sh
npm run check
npm run smoke
npm run pack:check
```
