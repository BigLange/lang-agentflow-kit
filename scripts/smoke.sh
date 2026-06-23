#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentflow-smoke.XXXXXX")"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

cd "$TMP_ROOT"
"$ROOT/bin/agentflow" init --profile standard
"$ROOT/bin/agentflow" feature create "fix login text" --type trivial
"$ROOT/bin/agentflow" feature create "fix pagination bug" --type bug
"$ROOT/bin/agentflow" feature create "admin permission system" --type sensitive
"$ROOT/bin/agentflow" board render --check
"$ROOT/bin/agentflow" feature context FEATURE-001-fix-login-text
"$ROOT/bin/agentflow" gate spec FEATURE-001-fix-login-text
"$ROOT/bin/agentflow" stage plan FEATURE-003-admin-permission-system --stage spec --adapter codex
"$ROOT/bin/agentflow" dispatch plan FEATURE-003-admin-permission-system --adapter codex
"$ROOT/bin/agentflow" doctor

test -f "$TMP_ROOT/features/FEATURE-001-fix-login-text/state.yml"
test -f "$TMP_ROOT/AGENTS.md"
test -f "$TMP_ROOT/project-docs/04_MANUAL_ACCEPTANCE.md"
grep -Fq 'MA-002-fix-pagination-bug' "$TMP_ROOT/project-docs/04_MANUAL_ACCEPTANCE.md"
test -f "$TMP_ROOT/features/FEATURE-002-fix-pagination-bug/test-cases.md"
test -f "$TMP_ROOT/features/FEATURE-002-fix-pagination-bug/test-results.md"
test -f "$TMP_ROOT/features/FEATURE-002-fix-pagination-bug/manual-acceptance.md"
test -f "$TMP_ROOT/features/FEATURE-002-fix-pagination-bug/model-routing.md"
grep -Fq 'Default model profile: medium' "$TMP_ROOT/features/FEATURE-002-fix-pagination-bug/model-routing.md"
test -f "$TMP_ROOT/features/FEATURE-003-admin-permission-system/reuse-analysis.md"
grep -Fq 'Default model profile: extra-high' "$TMP_ROOT/features/FEATURE-003-admin-permission-system/model-routing.md"
test -f "$TMP_ROOT/project-docs/records/dispatch/TASK-003-admin-permission-system_codex_plan/plan.md"
grep -Fq 'extra-high' "$TMP_ROOT/project-docs/records/dispatch/TASK-003-admin-permission-system_codex_plan/plan.md"
test -f "$TMP_ROOT/project-docs/records/dispatch/TASK-003-admin-permission-system_codex_stage_spec/plan.md"
grep -Fq 'Spec Creator' "$TMP_ROOT/project-docs/records/dispatch/TASK-003-admin-permission-system_codex_stage_spec/plan.md"
grep -Fq 'GENERATED FILE: DO NOT EDIT DIRECTLY.' "$TMP_ROOT/project-docs/03_TASK_BOARD.md"

printf 'AgentFlow smoke test passed\n'
