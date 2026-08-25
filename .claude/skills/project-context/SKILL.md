---
name: project-context
description: Answer questions about a project's context, issues, and domain by searching docs. Use when the user asks any question about project-level knowledge scoped to a named project folder under docs/.
---

# Project Context

## Workflow

1. Ask the user: **"Which project?"** If the project name is clear from context, skip the ask.
2. Run the freshness check:
   ```bash
   node .claude/skills/project-context/scripts/check-freshness.js <project>
   ```
   If the output says docs are stale or missing, warn the user before continuing:
   - **Stale (>24 h):** `"Docs for [project] were last synced [X hours/days] ago. They may be out of date — run /docs-generator to refresh."`
   - **Missing:** `"No docs found for [project]. Run /docs-generator to generate them first."`
   Continue regardless — stale docs are better than no answer.
3. Ask: **"What are you looking for?"** — a keyword, feature area, or issue number.
4. Run:
   ```bash
   node .claude/skills/project-context/scripts/search-project-docs.js <project> "<keyword>"
   ```
   The script prints matching file paths and excerpts. If no keyword, it lists all files.
   If it returns no matches, retry once with `--fuzzy` (matches the keyword's characters in order, tolerating typos or partial recall) before concluding there's nothing relevant.
   One search is usually enough. Only run a second exact search with a related term if the first returns fewer than 5 results.
5. Read the relevant files in full and answer the user's question.
   - When the answer concerns a specific task or issue, cite the issue tracker as the source of truth, not the synced doc.

## Script reference

```
check-freshness.js <project>

  project   Folder name under docs/

Output: staleness status — "ok", "stale", or "missing" — with age in hours.
Exit 0 always (stale docs are still usable).
```

```
search-project-docs.js <project> [keyword] [--fuzzy] [--case-sensitive]

  project           Folder name under docs/
  keyword           Optional. Search term. Matches file name or content.
  --fuzzy           Subsequence match instead of substring — use as a fallback when an
                     exact search returns nothing, to tolerate typos or partial recall.
  --case-sensitive  Disable the default case-insensitive matching.

Output: matching file paths + first matching line with context.
Exit 1 if the project folder does not exist.
```
