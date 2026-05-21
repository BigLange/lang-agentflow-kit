# Lang AgentFlow Kit

Lang AgentFlow Kit is a local project initializer for a subagent-first workflow.

## Install

After publishing to npm:

```sh
npm install -g lang-agentflow-kit
```

Then in any project:

```sh
agentflow init --profile standard
```

Without global install:

```sh
npx lang-agentflow-kit init --profile standard
```

From a GitHub repo:

```sh
npm install -g github:<owner>/<repo>
agentflow init --profile standard
```

From a downloaded source copy:

```sh
/path/to/lang-agentflow-kit/bin/agentflow init --profile standard
```

For local development from this package directory:

```sh
npm link
cd /path/to/project
agentflow init --profile standard
```

## Use

```sh
agentflow feature "Build user login"
agentflow dispatch FEATURE-001-build-user-login
agentflow archive FEATURE-001-build-user-login
```

## Profiles

- `lite`: AgentFlow core only.
- `standard`: AgentFlow core plus vendored Superpowers-style skills.
- `full`: Standard plus Oh My Codex adapter config.

The runtime path is subagent-first. Records are persisted under
`project-docs/records/`.

## What `init` Writes

`agentflow init` writes the workflow package into the current project:

```text
.agentflow/
  agents/
  templates/
  skills/                 # standard/full only
  integrations/           # full includes oh-my-codex.yml
AGENTS.md
agentflow.config.yml
project-docs/
  00_PROJECT_CONTEXT.md
  01_ARCHITECTURE.md
  02_API_SPEC.md
  03_TASK_BOARD.md
  records/
features/
```

The CLI itself stays installed globally or inside the downloaded package. The
generated `.agentflow/` directory makes each project self-contained.
