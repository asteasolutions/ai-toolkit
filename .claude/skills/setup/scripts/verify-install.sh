#!/usr/bin/env bash
# Static verification suite for a /setup install.
#   Usage: verify-install.sh <target-repo> [--no-skills] [--no-stance]
#     --no-skills  workflow skills declined: skip the workflow-skill checks
#     --no-stance  stance declined: skip the marked-region checks
# Checks everything provable in-process. Cross-harness runtime discovery (does /helm appear
# in each harness?) is NOT checkable here — /setup emits a manual checklist for that.
set -uo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
T="."; SKILLS=1; STANCE=1
for a in "$@"; do case "$a" in
  --no-skills) SKILLS=0 ;;
  --no-stance) STANCE=0 ;;
  *) T="$a" ;;
esac; done

CORE_SKILLS=(helm grill-me to-spec to-tickets tdd codebase-design diagnosing-bugs improve-codebase-architecture reconcile)
AGENTS_MAX_BYTES=$((12 * 1024))  # 12 KiB — well under Codex's 32 KiB silent truncation
pass=0; fail=0
chk(){ if eval "$2"; then printf '  ✅ %s\n' "$1"; pass=$((pass+1)); else printf '  ❌ %s\n' "$1"; fail=$((fail+1)); fi; }

echo "Verifying install at: $T (skills=$SKILLS stance=$STANCE)"
echo "-- always --"
chk "AGENTS.md present" '[ -f "$T/AGENTS.md" ]'
chk "AGENTS.md: no unfilled {{ }} placeholders (NEEDS CLARIFICATION is allowed)" '[ -f "$T/AGENTS.md" ] && ! grep -q "{{" "$T/AGENTS.md"'
chk "AGENTS.md: under ${AGENTS_MAX_BYTES} bytes (12 KiB)" '[ -f "$T/AGENTS.md" ] && [ "$(wc -c < "$T/AGENTS.md")" -le "$AGENTS_MAX_BYTES" ]'
chk ".scratch/ gitignored" 'grep -qx ".scratch/" "$T/.gitignore" 2>/dev/null'
if [ -f "$T/.github/copilot-instructions.md" ]; then
  chk "copilot-instructions.md does NOT reference AGENTS.md (Copilot loads it natively)" '! grep -q "AGENTS.md" "$T/.github/copilot-instructions.md"'
fi

if [ "$SKILLS" = 1 ]; then
  echo "-- workflow skills (selected) --"
  missing=""
  for s in "${CORE_SKILLS[@]}"; do [ -f "$T/.claude/skills/$s/SKILL.md" ] || missing="$missing $s"; done
  chk "9 core skills present under .claude/skills/${missing:+ (missing:$missing)}" '[ -z "$missing" ]'
  bundle_missing=""; installed_missing=""
  for s in "${CORE_SKILLS[@]}"; do
    template_dir="$TEMPLATES_DIR/$s"
    if [ ! -d "$template_dir" ]; then
      bundle_missing="$bundle_missing $s/"
      continue
    fi
    template_file_count=0
    while IFS= read -r template_file; do
      template_file_count=$((template_file_count+1))
      relative_path=${template_file#"$template_dir/"}
      [ -f "$T/.claude/skills/$s/$relative_path" ] || installed_missing="$installed_missing $s/$relative_path"
    done < <(find "$template_dir" -type f -print)
    [ "$template_file_count" -gt 0 ] || bundle_missing="$bundle_missing $s/"
  done
  chk "core skill folders match bundled templates${bundle_missing:+ (missing template bundles:$bundle_missing)}${installed_missing:+ (missing installed files:$installed_missing)}" '[ -z "$bundle_missing" ] && [ -z "$installed_missing" ]'
  chk ".claude/skills is a real directory (not a symlink)" '[ -d "$T/.claude/skills" ] && [ ! -L "$T/.claude/skills" ]'
else echo "  – workflow skills declined (checks skipped)"; fi

if [ "$STANCE" = 1 ]; then
  echo "-- stance block (selected) --"
  chk "AGENTS.md: setup:begin/end marked region intact" 'grep -q "<!-- setup:begin -->" "$T/AGENTS.md" 2>/dev/null && grep -q "<!-- setup:end -->" "$T/AGENTS.md" 2>/dev/null'
  chk "AGENTS.md: developer-led stance present" 'grep -q "developer-led" "$T/AGENTS.md" 2>/dev/null'
  if [ "$SKILLS" = 1 ]; then
    chk "AGENTS.md: /helm pointer present (skills installed)" 'grep -q "/helm" "$T/AGENTS.md" 2>/dev/null'
  else
    chk "AGENTS.md: no dangling /helm pointer (workflow skills declined)" '! grep -q "/helm" "$T/AGENTS.md" 2>/dev/null'
  fi
else echo "  – stance block not written (marked-region checks skipped)"; fi

echo "-- conditional (only for wired harnesses) --"
if [ -f "$T/CLAUDE.md" ] || [ -L "$T/CLAUDE.md" ] || [ -e "$T/.claude" ]; then
  chk "[claude] CLAUDE.md is a real file (not a symlink)" '[ -f "$T/CLAUDE.md" ] && [ ! -L "$T/CLAUDE.md" ]'
  chk "[claude] CLAUDE.md imports @AGENTS.md" 'grep -q "@AGENTS.md" "$T/CLAUDE.md" 2>/dev/null'
else echo "  – claude not wired (skipped)"; fi
S="$T/.vscode/settings.json"
chk "[copilot] .vscode/settings.json present" '[ -f "$S" ]'
chk "[copilot] chat.useAgentsMdFile: true" '[ -f "$S" ] && grep -q "\"chat.useAgentsMdFile\"[[:space:]]*:[[:space:]]*true" "$S"'
chk "[copilot] chat.useClaudeMdFile: false" '[ -f "$S" ] && grep -q "\"chat.useClaudeMdFile\"[[:space:]]*:[[:space:]]*false" "$S"'
chk "[copilot] chat.includeApplyingInstructions: true" '[ -f "$S" ] && grep -q "\"chat.includeApplyingInstructions\"[[:space:]]*:[[:space:]]*true" "$S"'
chk "[copilot] chat.includeReferencedInstructions: true" '[ -f "$S" ] && grep -q "\"chat.includeReferencedInstructions\"[[:space:]]*:[[:space:]]*true" "$S"'
chk "[copilot] chat.agentSkillsLocations includes .claude/skills" '[ -f "$S" ] && grep -A3 "\"chat.agentSkillsLocations\"" "$S" | grep -q "\.claude/skills\"[[:space:]]*:[[:space:]]*true"'
chk "[copilot] chat.agentFilesLocations: .github/agents on, .claude/agents off" '[ -f "$S" ] && grep -A4 "\"chat.agentFilesLocations\"" "$S" | grep -q "\.github/agents\"[[:space:]]*:[[:space:]]*true" && grep -A4 "\"chat.agentFilesLocations\"" "$S" | grep -q "\.claude/agents\"[[:space:]]*:[[:space:]]*false"'
chk "[copilot] chat.instructionsFilesLocations: .github/instructions on, .claude/rules off" '[ -f "$S" ] && grep -A4 "\"chat.instructionsFilesLocations\"" "$S" | grep -q "\.github/instructions\"[[:space:]]*:[[:space:]]*true" && grep -A4 "\"chat.instructionsFilesLocations\"" "$S" | grep -q "\.claude/rules\"[[:space:]]*:[[:space:]]*false"'

echo "-- result --"
echo "PASS=$pass FAIL=$fail"
[ "$fail" = "0" ] || { echo "INSTALL INCOMPLETE — fix the failures above and re-run." >&2; exit 1; }
echo "Install verified."
