#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentflow-extmod-smoke.XXXXXX")"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

cd "$TMP_ROOT"
"$ROOT/bin/agentflow" init --profile standard
"$ROOT/bin/agentflow" module list
"$ROOT/bin/agentflow" module add public-admin-template \
  --name "Public Admin Template" \
  --source-type public \
  --source github:example/admin-template \
  --module-type template \
  --domain admin \
  --risk high \
  --mode reference-only
"$ROOT/bin/agentflow" module show public-admin-template
"$ROOT/bin/agentflow" module contract public-admin-template
"$ROOT/bin/agentflow" feature create "admin user permission"
"$ROOT/bin/agentflow" reuse analyze FEATURE-001-admin-user-permission
"$ROOT/bin/agentflow" reuse gate FEATURE-001-admin-user-permission

test -f "$TMP_ROOT/.agentflow/modules/external_modules.yml"
test -f "$TMP_ROOT/.agentflow/modules/external_module_policy.yml"
test -f "$TMP_ROOT/.agentflow/modules/public-admin-template/module-contract.yml"
test -f "$TMP_ROOT/.agentflow/modules/public-admin-template/security-notes.md"
test -f "$TMP_ROOT/.agentflow/modules/public-admin-template/integration-notes.md"
test -f "$TMP_ROOT/features/FEATURE-001-admin-user-permission/reuse-analysis.md"
test -f "$TMP_ROOT/features/FEATURE-001-admin-user-permission/external-module-risk.md"

printf 'AgentFlow external module smoke test passed\n'
