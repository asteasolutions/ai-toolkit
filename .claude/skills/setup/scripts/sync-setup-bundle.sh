#!/usr/bin/env bash
# Regenerate the setup skill's bundled content — or --check for drift.
#
# Maintenance tool for the SOURCE repo only:
# - Live core skills under .claude/skills/ generate setup/templates/.
# - docs/ai-repo-setup-blueprint.md generates setup/references/blueprint.md.
#
#   sync-setup-bundle.sh           regenerate bundled content
#   sync-setup-bundle.sh --check   exit non-zero if bundled content drifted
#   sync-setup-bundle.sh --check-index
#                                  exit non-zero if staged content drifted
set -euo pipefail

CORE_SKILLS=(helm grill-me to-spec to-tickets tdd codebase-design diagnosing-bugs improve-codebase-architecture reconcile)

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKILLS_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)   # .claude/skills (live, canonical)
TEMPLATES_DIR="$SCRIPT_DIR/../templates"      # setup/templates (derived)
REPO_ROOT=$(cd "$SKILLS_DIR/../.." && pwd)
BLUEPRINT_SOURCE_REL="docs/ai-repo-setup-blueprint.md"
BLUEPRINT_BUNDLE_REL=".claude/skills/setup/references/blueprint.md"
BLUEPRINT_SOURCE="$REPO_ROOT/$BLUEPRINT_SOURCE_REL"
BLUEPRINT_BUNDLE="$REPO_ROOT/$BLUEPRINT_BUNDLE_REL"

case "${1:-}" in
  "") mode="sync" ;;
  "--check") mode="check" ;;
  "--check-index") mode="check-index" ;;
  *)
    echo "Usage: $0 [--check|--check-index]" >&2
    exit 2
    ;;
esac
[ "$#" -le 1 ] || { echo "Usage: $0 [--check|--check-index]" >&2; exit 2; }

# Home-repo guard. "Home" is not a flag — it is, by definition, the repo where the
# canonical core skills live as siblings of this skill. Discover it by looking: if
# any are absent, this is not the home repo, so refuse rather than guess.
missing_live=""
for s in "${CORE_SKILLS[@]}"; do [ -d "$SKILLS_DIR/$s" ] || missing_live="$missing_live $s"; done
if [ -n "$missing_live" ]; then
  echo "Not the setup skill's home repo: canonical core skills are not present as siblings under $SKILLS_DIR (missing:$missing_live)." >&2
  echo "sync-setup-bundle.sh only runs in the source repo; installed setup bundles have no canonical sources to sync from." >&2
  exit 2
fi
if [ ! -f "$BLUEPRINT_SOURCE" ]; then
  echo "Canonical blueprint not found: $BLUEPRINT_SOURCE" >&2
  exit 2
fi

index_manifest() {
  local prefix=$1 entry metadata path
  while IFS= read -r -d '' entry; do
    metadata=${entry%%$'\t'*}
    path=${entry#*$'\t'}
    printf '%s\0%s\0' "${path#"$prefix/"}" "$metadata"
  done < <(git -C "$REPO_ROOT" ls-files --stage -z -- "$prefix")
}

drift=0
if [ "$mode" = "check-index" ]; then
  for s in "${CORE_SKILLS[@]}"; do
    live_rel=".claude/skills/$s"
    tpl_rel=".claude/skills/setup/templates/$s"
    if ! cmp -s <(index_manifest "$live_rel") <(index_manifest "$tpl_rel"); then
      echo "STAGED DRIFT: '$s' differs between live skill and templates/"
      drift=1
    fi
  done

  source_blob=$(git -C "$REPO_ROOT" rev-parse --verify ":$BLUEPRINT_SOURCE_REL" 2>/dev/null || true)
  bundle_blob=$(git -C "$REPO_ROOT" rev-parse --verify ":$BLUEPRINT_BUNDLE_REL" 2>/dev/null || true)
  if [ -z "$source_blob" ] || [ -z "$bundle_blob" ] || [ "$source_blob" != "$bundle_blob" ]; then
    echo "STAGED DRIFT: 'references/blueprint.md' differs from docs/ai-repo-setup-blueprint.md"
    drift=1
  fi

  if [ "$drift" = "1" ]; then
    echo "staged setup bundle is STALE — stage the canonical and generated files together." >&2
    exit 1
  fi
  echo "staged setup bundle is in sync."
  exit 0
fi

for s in "${CORE_SKILLS[@]}"; do
  live="$SKILLS_DIR/$s"
  tpl="$TEMPLATES_DIR/$s"
  if [ "$mode" = "check" ]; then
    if ! diff -rq "$live" "$tpl" >/dev/null 2>&1; then
      echo "DRIFT: '$s' differs between live skill and templates/"
      drift=1
    fi
  else
    rm -rf "$tpl"
    mkdir -p "$TEMPLATES_DIR"
    cp -R "$live" "$tpl"
    echo "synced: $s"
  fi
done

if [ "$mode" = "check" ]; then
  if ! cmp -s "$BLUEPRINT_SOURCE" "$BLUEPRINT_BUNDLE"; then
    echo "DRIFT: 'references/blueprint.md' differs from docs/ai-repo-setup-blueprint.md"
    drift=1
  fi
else
  cp "$BLUEPRINT_SOURCE" "$BLUEPRINT_BUNDLE"
  echo "synced: references/blueprint.md"
fi

if [ "$mode" = "check" ]; then
  if [ "$drift" = "1" ]; then
    echo "setup bundle is STALE — run sync-setup-bundle.sh to regenerate." >&2
    exit 1
  fi
  echo "setup bundle is in sync."
fi
