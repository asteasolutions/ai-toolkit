---
name: docs-generator
description: Sync issue-tracker tickets into docs/ markdown files. Use when the user wants to export or refresh project backlog docs from an issue tracker.
---

# Docs Generator

Sync one markdown file per issue for a chosen project from your connected issue tracker MCP server.

## Workflow

### Step 0 — Check for existing docs (sync vs. fresh fetch)

Before doing anything, determine whether the project name is known from the user's request.

- If the project name is unknown, skip the manifest check for now. Complete Step 1, then ask the user for the project name before Step 2. Once Step 2 resolves exactly one project, return to this manifest check before Step 3.
- If the project name is known, check whether `docs/[project-name]/_manifest.json` already exists. If it does:

1. Read `last_synced_at` from the manifest.
2. Tell the user: `"Docs for [project] were last synced on [date]. Fetch only issues updated since then, or re-fetch everything?"`
3. If the user picks **incremental**, pass `updated_after=[last_synced_at]` when listing issues in Step 3.
   - If the incremental fetch returns 0 issues, update `last_synced_at` in the manifest to the current time and tell the user: `"All docs are up to date — no issues changed since [date]."` Then stop.
4. If the user picks **full re-fetch**, continue with the next unresolved step: Step 1 on a fresh run, or Step 3 if you returned here after Step 2.

If no manifest exists (first run), continue with the next unresolved step: Step 1 on a fresh run, or Step 3 if you returned here after Step 2.

### Step 1 — Identify available platforms

Check `.mcp.json` to see which issue-tracker MCP servers are configured. If only one is found, proceed with it. If multiple are found, ask the user which one to use.

### Step 2 — Find the project

Using the chosen platform's MCP tools, search for the project by name. If the search returns no results, tell the user: `"No project found matching '[name]'."` and stop.

If multiple projects match, list them and ask the user to confirm which one.

### Step 3 — Fetch all issues for the project

Fetch **all** issues regardless of state (open and closed). Paginate until no further pages remain.

### Step 4 — Write one file per issue

For each issue, create a file. Do not proceed to Step 5 until every fetched issue has a corresponding file.

**Output directory:** `docs/[project-name]/` (create if it doesn't exist). Use the project name as returned by the MCP server, slugified to lowercase-kebab-case.

**Filename:** `[iid]-[slugified-title].md`
- Slugify: lowercase, replace spaces and special characters with hyphens, collapse consecutive hyphens
- Cap the slug at 60 characters (trim at the last full word before the limit)
- Example: issue #42 "Fix login bug on mobile" → `42-fix-login-bug-on-mobile.md`

**Format:** Follow the template in `references/issue-template.md`. Key fields:
- **Status**: `open` or `closed`
- **Labels**: all label names exactly as returned by the tracker, comma-separated (e.g. `bug, enhancement, mobile`). Write `none` if there are no labels.
- Omit the **Comments** section if the issue has no comments
- Omit the **Sprint** section if the issue has no sprint/milestone

Do not ask the user where to save files — always use `docs/[project-name]/`.

### Step 5 — Write the sync manifest

After all files are written (or updated), write `docs/[project-name]/_manifest.json` to record the completed sync:

```json
{
  "project": "[project-name]",
  "platform": "[detected platform name]",
  "last_synced_at": "[ISO 8601 UTC timestamp]",
  "issue_count": 42
}
```

Use the current UTC time for `last_synced_at`. For incremental syncs, update `last_synced_at` and add the count of newly synced files to `issue_count`. The sync is complete when the manifest is written.

## Field mapping

Field names and tool signatures vary by tracker. Do not hardcode a specific platform's tool names — discover the right tool and field for the connected MCP server before relying on it:

- **Fetch all states:** find the way this tracker's issue-listing tool includes both open and closed issues — an explicit flag (e.g. `state=all`), or omitting a status filter entirely (e.g. leaving status out of a JQL query).
- **Labels:** use whatever the tool returns for labels/tags exactly as given — do not map or normalize them. If the tracker has no `labels`-shaped field, use its closest equivalent (e.g. an issue-type field).
- **Sprint/milestone:** look for a milestone, sprint, or iteration field on the issue and use its display name.
- **Comments:** Not every MCP server exposes a discussions/comments tool. Before writing any issue files, discover the available comments or discussions tool for the current harness (for example, search for `"comments discussions issues"`). If a matching tool is found, use it per issue to fetch user comments — filter out system-generated notes and write the remaining ones. If only a first page was fetched and there are more, add a note: `<!-- [N] total comments; first page shown -->`. If no such tool exists, omit the Comments section from all files silently.
- **Incremental sync:** find this tracker's parameter for filtering by update time (e.g. `updated_after`, or a JQL `updated >=` clause) and pass the manifest's `last_synced_at`.

If a tracker's field mapping is ambiguous, ask the user to clarify rather than guessing.
