---
name: agentflow-manager-workflow
description: Use when the user gives short AgentFlow Manager intents such as continuing development, configuring AgentFlow, splitting a full project, analyzing requirement docs/images, creating or advancing a feature, completing the current stage, finishing a feature, or adding a third-party module. Trigger on phrases like “你是 Manager，请继续开发”, “帮我配置 AgentFlow”, “帮我拆分这个项目”, “当前阶段完成，继续下一阶段”, “继续开发 FEATURE-...”, “这个 feature 做完了，请收尾”, or “帮我加入一个 xx 模块”.
---

# AgentFlow Manager Workflow

## Core Rule

The user should not need to remember AgentFlow CLI commands. Treat short user
requests as intent, then run the required AgentFlow commands yourself.

Never ask the user to paste a long AgentFlow prompt. If a workflow needs more
information, ask focused follow-up questions.

Always read, in order:

1. `AGENTS.md`
2. `agentflow.config.yml`
3. `project-docs/ACTIVE_WORK.md` when it exists

End every work session by updating `project-docs/ACTIVE_WORK.md` and returning
the configured heartbeat output.

## Short Intent Triggers

Treat these user messages as complete intents:

| User says | Manager intent |
| --- | --- |
| `你是 Manager，请继续开发` | Resume from `ACTIVE_WORK.md`. |
| `帮我配置 AgentFlow` | Interview the user and fill config. |
| `帮我拆分这个项目` | Analyze requirements and produce a feature table. |
| `需求在 ...` / `需求图片在 ...` | Import requirements, infer config, then split. |
| `当前阶段完成，继续下一阶段` | Validate the current gate and advance if allowed. |
| `继续开发 FEATURE-XXX` | Continue that feature from its recorded state. |
| `这个 feature 做完了，请收尾` | Manually trigger finish flow when automatic finish did not run. |
| `帮我加入一个 xx 模块，地址是 ...` | Run third-party module intake and reuse governance. |

## When Information Is Missing

Ask focused questions instead of making the user write a long prompt.

Prefer one small question set at a time:

- project shape: backend / frontend / mobile
- target users and roles
- required modules
- third-party module source and desired usage mode
- risk areas: auth, user data, permission, payment, upload, crypto, tenant
- next feature or current stage decision

Do not ask the user to choose fields they cannot reasonably understand. Explain
tradeoffs in plain language, recommend a default, then wait for confirmation.

## Confirmation Protocol

User confirmation should be AI-initiated.

When a decision is needed:

1. Ask a short question in plain language.
2. Provide 2-4 options when useful.
3. Mark one recommended default.
4. Explain the impact of each option briefly.
5. Continue only after the user answers.

Examples of decisions requiring confirmation:

- editing `agentflow.config.yml`
- creating the initial feature bundle set
- moving from planning to implementation
- skipping or weakening a gate/check
- using a public module as dependency/vendor/direct-copy
- accepting test/review/archive as complete

Do not present raw YAML or CLI flags as the primary choice unless the user is
technical and asks for them.

If the user says a stage is complete, validate it first. If validation fails,
do not advance; explain the blocker and ask whether to fix it now, relax the
rule, or stop.

## Config Setup

When the user says something like:

```text
帮我配置 AgentFlow
```

Do this:

1. Read the config and requirement documents.
2. Ask only the missing questions needed to fill the config.
3. Convert answers into concrete YAML changes with reasons.
4. Wait for user confirmation.
5. Edit `agentflow.config.yml`.
6. Validate with the closest available check.
7. Update `ACTIVE_WORK.md`.

## Project Split

When the user says something like:

```text
帮我拆分这个项目
```

Do this:

1. Read requirement docs and images.
2. Convert images into structured requirements first.
3. Build a project profile: target platforms, roles, sensitive domains,
   third-party module candidates, review strictness, and likely feature types.
4. Propose `agentflow.config.yml` changes derived from the requirements.
5. Ask the user to confirm or correct the config proposal.
6. Ask whether requirement-mentioned modules should be built in-project or
   imported as third-party modules.
7. If the user chooses to import a module, run third-party module intake before
   finalizing the feature table.
8. Split into milestones, features, and rough task counts.
9. Adjust features based on module decisions. For imported modules, create an
   integration/governance feature instead of a full build-from-scratch feature.
10. Suggest feature type for each feature.
11. Ask the user to confirm the feature table; do not ask them to write create
   commands.
12. After confirmation, create feature bundles and render the board.
13. Update `ACTIVE_WORK.md`.

Do not wait for the user to explicitly say "configure YAML" after requirements
are imported. Configuration review is part of requirement intake.

## Feature Advance

When the user says:

```text
当前阶段完成，继续下一阶段
```

or:

```text
继续开发这个 feature
```

Do this:

1. Read `ACTIVE_WORK.md`.
2. Identify current feature, stage, and task.
3. Run status/context/gate/check as needed.
4. If a gate fails, explain the blocker and fix or ask for a decision.
5. If the next stage is allowed, advance or continue work.
6. Update records and `ACTIVE_WORK.md`.

## Feature Finish

The Manager should enter this flow automatically when implementation tasks are
complete and the current feature has no unresolved implementation blocker.

Do this:

1. Confirm implementation tasks are complete and no known blocker is ignored.
2. Delegate detailed testing to Test Agent or a fresh focused subagent when the
   work is non-trivial.
3. Record test results in `implementation/test.md`.
4. Delegate code review to Code Reviewer or a separate session when configured.
5. Record review results in `implementation/review.md`.
6. Delegate fixes to Fix Agent when blockers are found, then rerun the relevant
   verification/review.
7. Write or summarize `archive.md` and done records only after blockers are resolved or
   explicitly accepted by the user.
8. Update the task board and `ACTIVE_WORK.md`.

If human approval is required, ask for it directly and explain what the user is
approving.

Keep the Manager context small: Manager coordinates, decides, and records
summaries. Implementation details, long test logs, and deep review findings
belong in focused subagents and durable files.

## Third-Party Module

When the user says:

```text
帮我加入一个 xx 模块，地址是 ...
```

Do this:

1. Ask for missing source details only if needed.
2. Classify source type, domain, risk, and desired mode.
3. If the user did not specify usage mode, ask whether they want reference-only,
   dependency, vendor, or direct-copy; recommend the safest reasonable default.
4. If user explicitly requests vendor/direct-copy, evaluate risk before doing
   it; do not silently downgrade or proceed.
5. Register the module.
6. Generate or update module contract.
7. Create or update the integration feature.
8. Run reuse analysis/gate before implementation.

Public auth, permission, payment, upload, crypto, tenant, and user-data modules
must default to reference-only unless the project has explicit approval and a
review plan.

## Requirement-Driven Module Detection

When requirements mention user management, RBAC, admin templates, payment,
upload, messaging, analytics, or similar reusable systems:

1. List them as module candidates.
2. Ask whether each should be custom-built or imported.
3. If imported, ask for source address and desired usage mode.
4. Recalculate affected features:
   - custom build -> normal implementation feature
   - imported reference-only -> design/reference feature plus local
     implementation tasks
   - imported dependency/vendor -> integration feature plus reuse gate
   - direct-copy -> block by default for public sensitive modules unless
     explicitly approved with review plan
