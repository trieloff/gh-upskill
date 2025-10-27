#!/usr/bin/env bash
set -Eeo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"

require_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! require_cmd gh; then
  echo "SKIP: gh CLI not installed" >&2
  exit 0
fi

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

pushd "$TMP" >/dev/null

echo "Running upskill (first run) ..."
"$ROOT_DIR/upskill" adobe/helix-website -b agent-skills

test -d .claude/skills || { echo "FAIL: .claude/skills missing"; exit 1; }
count_skills=$(find .claude/skills -name 'SKILL.md' -type f | wc -l | tr -d ' ')
if [[ "$count_skills" -le 0 ]]; then
  echo "FAIL: No SKILL.md files copied"
  exit 1
fi

test -x .agents/discover-skills || { echo "FAIL: .agents/discover-skills not executable"; exit 1; }

echo "Checking AGENTS.md markers ..."
marker_start='<!-- upskill:skills:start -->'
marker_end='<!-- upskill:skills:end -->'
grep -qF "$marker_start" AGENTS.md || { echo "FAIL: start marker missing"; exit 1; }
grep -qF "$marker_end" AGENTS.md || { echo "FAIL: end marker missing"; exit 1; }

count_markers=$(grep -cF "$marker_start" AGENTS.md)
[[ "$count_markers" == "1" ]] || { echo "FAIL: duplicate start markers on first run"; exit 1; }

echo "Running upskill (second run) ..."
"$ROOT_DIR/upskill" adobe/helix-website -b agent-skills

count_markers2=$(grep -cF "$marker_start" AGENTS.md)
[[ "$count_markers2" == "1" ]] || { echo "FAIL: duplicate start markers after second run"; exit 1; }

echo "Running discover-skills ..."
out="$(.agents/discover-skills | sed -n '1,40p')"
echo "$out" | grep -q "Available Skills:" || { echo "FAIL: discover-skills header missing"; exit 1; }
echo "$out" | grep -q -- "---" || { echo "FAIL: discover-skills separator missing"; exit 1; }

# Test gitignore insertion with -i
echo "Running upskill with -i ..."
"$ROOT_DIR/upskill" -i adobe/helix-website -b agent-skills

test -f .gitignore || { echo "FAIL: .gitignore not created"; exit 1; }
grep -qF ".claude/skills/" .gitignore || { echo "FAIL: .gitignore missing skills entry"; exit 1; }
grep -qF ".agents/discover-skills" .gitignore || { echo "FAIL: .gitignore missing discover entry"; exit 1; }

# Ensure idempotent block
start_marker="# upskill:gitignore:start"
[[ $(grep -cF "$start_marker" .gitignore) == "1" ]] || { echo "FAIL: duplicate gitignore block after first -i"; exit 1; }
"$ROOT_DIR/upskill" -i adobe/helix-website -b agent-skills
[[ $(grep -cF "$start_marker" .gitignore) == "1" ]] || { echo "FAIL: duplicate gitignore block after second -i"; exit 1; }

echo "OK"

popd >/dev/null
