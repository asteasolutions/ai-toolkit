---
name: setup
description: Project an existing canonical .claude setup to GitHub Copilot, or fully AI-enable a repository for Claude Code and Copilot with shared instructions and the developer-led workflow. Re-runnable; converges the repo on the layout.
disable-model-invocation: true
---

# Setup — project or fully AI-enable a repo

Project an existing Claude Code setup to GitHub Copilot, or lay the full minimal set of artifacts that make a repo behave effectively under both harnesses. Full setup ships with the **developer-led method** as its baseline; the `/helm` loop is its centre of gravity, not its boundary.

The installed layout is the **harness-agnostic blueprint**: `AGENTS.md` is the single source of shared instructions, `.claude/` directories are the sources of truth for skills/agents/rules, and committed VS Code settings bridge Copilot to both. **This flow targets Claude Code and GitHub Copilot only.** Full design lives in [`references/blueprint.md`](references/blueprint.md) — inside this skill, no external docs required.

> **This is prompt-driven, not a script.** Present the path choice first. Then explore, preview, confirm, and write only what that path permits.

> **Scope.** Handles both **greenfield** (clean repo) and **brownfield** (existing AI config). Brownfield is a **migration**: a gated conversion of what's there into the canonical layout, one declinable move at a time — see [`references/migration.md`](references/migration.md).

> **Agent / rule projection.** Both paths follow [`PROJECTION.md`](PROJECTION.md) first — the bundled CLI generates owned `.github/` mirrors. Do not hand-sync.

## The canonical layout

```
repo/
├── AGENTS.md                     # single source of shared instructions, all harnesses
├── CLAUDE.md                     # real file: "@AGENTS.md" import + Claude-only extras (not a symlink)
├── .vscode/settings.json         # committed chat.* settings that wire Copilot (pinned by harness-projection sync)
├── .claude/
│   ├── skills/                   # skills home — Claude reads it natively, Copilot via chat.agentSkillsLocations
│   ├── agents/                   # source of truth for agent definitions (created by migration only)
│   └── rules/                    # source of truth for path-scoped rules (created by migration only)
├── .github/
│   ├── agents/                   # derived from .claude/agents/ via harness-projection (do not edit)
│   └── instructions/             # derived from .claude/rules/ via harness-projection (do not edit)
└── .gitignore                    # .scratch/ ignored
```

`.github/copilot-instructions.md` is **not** created — Copilot loads `AGENTS.md` natively via `chat.useAgentsMdFile`, and restating or linking `AGENTS.md` there would double-load it. If the file exists it may carry only genuinely Copilot-only extras.

## Process

### 1. Choose one path

Start by offering exactly this choice:

```text
What should /setup do?

1. Harness projection only
   Use the existing .claude agents, rules, and skills with Claude Code
   and Copilot. Requires the .claude setup to be ready.

2. Full repository setup
   Run harness projection first, then configure shared instructions,
   workflow skills, developer-led rules, and scratch space.
```

Both paths target **Claude Code and GitHub Copilot only**. Do not offer a harness-selection question.

### 2. Path 1 — Harness projection only

#### Preconditions and boundaries

- The developer must already have the desired canonical files under `.claude/`. Treat `.claude/` as the source of truth and `.github/` as generated Copilot output.
- Do not reverse-import GitHub-only agents or instructions. Do not create missing canonical agents or rules for the developer.
- Unmanaged `.github/` collisions stop projection and remain untouched.
- Skills are not translated. Projection points Copilot at the existing `.claude/skills/` directory.

#### Read, wire, run, verify

1. **Before running projection**, point the developer to these repository-relative documents:
   - [`PROJECTION.md`](PROJECTION.md) — **required reading**
   - [`references/blueprint.md`](references/blueprint.md) — **required reading**
   - [`references/projection-guide.html`](references/projection-guide.html) — optional visual guide
2. Follow `PROJECTION.md` to detect the package manager and wire or present the appropriate commands. Add the two scripts without disturbing existing `package.json` scripts. Do not create `package.json` when it is absent.
3. Run interactive `sync`. Show every unresolved projection question to the developer and wait for their answer; never answer it for them.
4. Run the non-interactive `check`.
5. If `sync` or `check` fails, diagnose the cause, make the smallest safe repair, and rerun it. Do not report success while projection is incomplete or drifting.

Path 1 ends here. Do not create `AGENTS.md`, `CLAUDE.md`, `.scratch/`, workflow skills, or a stance block.

### 3. Path 2 — Full repository setup

Path 2 runs all of Path 1 first. If projection fails, stop immediately and do not install or modify any additional setup pieces.

#### Explore and confirm

After projection succeeds, read; don't assume. Follow [`references/discovery.md`](references/discovery.md).

- **Greenfield vs brownfield** — if AI config already exists, plan only applicable conversion moves from [`references/migration.md`](references/migration.md). Every proposed edit to existing developer content must be individually reviewable and declinable.
- **Stack + commands** — infer the project's overview and real build/test/run/lint/**verify** commands from manifests and CI, preferring declared commands.
- **Domain knowledge docs** — if the repo already has them (glossaries, decision logs, context maps, …), note that they exist so skills can discover and follow them. Do **not** seed or invent a layout.

Present the discovered `AGENTS.md` draft, including any `[NEEDS CLARIFICATION]` placeholders, and preview every automatic-base edit before writing:

1. Create or update a repo-tailored `AGENTS.md` with the project overview and commands. Do not silently overwrite existing content.
2. Create a real `CLAUDE.md` importing `@AGENTS.md`. Preserve and preview any existing Claude-only content.
3. Append `.scratch/` to `.gitignore`, creating `.gitignore` only when absent.

Keep these as two separate choices:

1. **Install the workflow skills?** Recommended default **Yes**. When Yes, preview which of the nine are missing versus same-named skills already present (in `.claude/skills/` or still awaiting relocation) — conflicts need an explicit keep-or-replace decision; never silent overwrite.
2. **Add the developer-led stance to `AGENTS.md`?** Recommended default **Yes**.

#### Write

Only after the preview and choices are confirmed:

1. Apply the approved automatic-base edits. Strip the `<!-- fill: … -->` template comments; preserve the load-bearing `<!-- setup:begin/end -->` markers when the stance is selected.
2. Apply approved **skill-relocation** brownfield moves first (migration catalogue item 4 — skills outside `.claude/skills/`). Customized skills must land at the canonical path before any template install, so a later same-name check protects them.
3. If workflow skills are selected, copy each of the nine bundled skill folders from `templates/` into `.claude/skills/` (whole-folder, siblings included). Stop if any folder cannot be copied completely. If a same-named skill already exists at the destination, **do not overwrite** — show the difference and ask (same guard as migration catalogue item 4).
4. If the stance is selected, add or update only the marked stance block. Include its `/helm` pointer only when workflow skills are installed. Follow `references/migration.md` for existing-repository behaviour conflicts.
5. Apply remaining approved brownfield conversion moves exactly as previewed. Always resolve file or layout conflicts that block an approved addition; never reverse-import GitHub-only agents or instructions. Do **not** create domain-knowledge layout files.

#### Verify

Run the projection check, then the built-in installation verifier with the selected choice state:

```
scripts/verify-install.sh <target> [--no-skills] [--no-stance]
```

Pass `--no-skills` and/or `--no-stance` when those choices were declined. The verifier checks `AGENTS.md`, `.scratch/`, the selected workflow and stance pieces, `CLAUDE.md`, and the Copilot VS Code settings. If either check fails, diagnose the cause, make the smallest safe repair, and rerun both relevant checks. Never report a complete setup while a check fails.

### 4. Completion summary

For either path, repeat these pointers in the completion summary:

- [`PROJECTION.md`](PROJECTION.md) — **required reading**
- [`references/blueprint.md`](references/blueprint.md) — **required reading**
- [`references/projection-guide.html`](references/projection-guide.html) — optional visual guide

For full setup, also emit the manual cross-harness discovery checklist: confirm Copilot loads `AGENTS.md` and projected agents without duplicates; confirm Claude Code imports `AGENTS.md`. Include `/helm` discovery checks only when workflow skills were installed.

---

*Maintaining this skill (keeping the bundled `templates/` in sync) is a concern for the skill's home repo, not for running `/setup` — see `MAINTAINERS.md`.*
