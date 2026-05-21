#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="${1:-$(pwd)}"
PROFILE="standard"

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh [target-project-root] [--profile lite|standard|full]

Installs Lang AgentFlow Kit into the target project:
  - bin/agentflow
  - agentflow/
  - agentflow.config.yml
  - AGENTS.md and project-docs via bin/agentflow init
USAGE
}

copy_path() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" ]]; then
    printf 'Skip existing: %s\n' "$dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
  printf 'Installed: %s\n' "$dest"
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  if [[ $# -gt 0 && "${1:-}" != --* ]]; then
    TARGET_ROOT="$1"
    shift
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        if [[ $# -lt 2 ]]; then
          printf 'Missing value for --profile\n' >&2
          exit 1
        fi
        PROFILE="$2"
        shift 2
        ;;
      --profile=*)
        PROFILE="${1#--profile=}"
        shift
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        exit 1
        ;;
    esac
  done

  case "$PROFILE" in
    lite|standard|full) ;;
    *)
      printf 'Unknown profile: %s\n' "$PROFILE" >&2
      exit 1
      ;;
  esac

  if [[ ! -d "$TARGET_ROOT" ]]; then
    printf 'Target project root does not exist: %s\n' "$TARGET_ROOT" >&2
    exit 1
  fi

  copy_path "$SOURCE_ROOT/bin" "$TARGET_ROOT/bin"
  copy_path "$SOURCE_ROOT/agentflow" "$TARGET_ROOT/agentflow"
  copy_path "$SOURCE_ROOT/agentflow.config.yml" "$TARGET_ROOT/agentflow.config.yml"

  chmod +x "$TARGET_ROOT/bin/agentflow"
  (cd "$TARGET_ROOT" && "$TARGET_ROOT/bin/agentflow" init --profile "$PROFILE")

  printf '\nLang AgentFlow Kit installed in %s with profile: %s\n' "$TARGET_ROOT" "$PROFILE"
  printf 'Try: %s/bin/agentflow feature "your feature"\n' "$TARGET_ROOT"
}

main "$@"
