# Using harness-projection

> Both `/setup` paths begin with this flow (see `SKILL.md`). Use this file
> day-to-day after install whenever agents or rules change.

Keep one set of agents and rules in **Claude Code's** format; this tool
generates the **GitHub Copilot / VS Code** equivalents so Copilot users get the
same agents with no second copy to maintain by hand. You edit only the
`.claude/` side — the `.github/` and `.vscode/` files are generated and must
never be hand-edited.

**The tool** ships with this skill as a single file:
`.claude/skills/setup/scripts/harness-projection.mjs`. Requires Node.js 20+.
Nothing else — no `npm install`, no network access.

## Setup (once)

1. **Wire the commands.** If the repo has a `package.json`, add these two
   scripts without disturbing any existing scripts:

   ```json
   "harness-setup:sync": "node .claude/skills/setup/scripts/harness-projection.mjs sync",
   "harness-setup:check": "node .claude/skills/setup/scripts/harness-projection.mjs check"
   ```

   Present and run the script through the repository's package manager. Prefer
   the `"packageManager"` field, then an unambiguous lockfile. If detection is
   ambiguous, ask the developer rather than guessing:

   | Package manager | Sync | Check |
   |---|---|---|
   | npm | `npm run harness-setup:sync` | `npm run harness-setup:check` |
   | pnpm | `pnpm run harness-setup:sync` | `pnpm run harness-setup:check` |
   | Yarn | `yarn harness-setup:sync` | `yarn harness-setup:check` |
   | Bun | `bun run harness-setup:sync` | `bun run harness-setup:check` |

   **No `package.json`?** Do not create one. Skip the scripts and run the file
   with Node directly:

   ```sh
   node .claude/skills/setup/scripts/harness-projection.mjs sync
   node .claude/skills/setup/scripts/harness-projection.mjs check
   ```

2. **Confirm the developer has authored the desired canonical sources under
   `.claude/`.** `/setup` does not create missing agents or rules:

   - `.claude/agents/<name>.md` — one agent per file (frontmatter: `name`,
     `description`, optional `tools`; body is the system prompt).
   - `.claude/rules/<name>.md` — optional scoped instructions (must declare a
     `paths` list; always-on guidance belongs in `AGENTS.md`).
   - `AGENTS.md` at the repo root for always-on shared guidance, and a
     `CLAUDE.md` containing just `@AGENTS.md` so Claude Code imports it.

3. **Run the wizard** with the detected package-manager command, or the direct
   `node … sync` command above when there is no `package.json`, then answer its
   questions.

4. **Commit** everything it created or changed: the generated files under
   `.github/`, the updated `.vscode/settings.json`, the saved decisions in
   `.harness-projection/decisions.json`, and (if you added them) your
   `package.json` scripts.

## Running sync — keep it interactive

`sync` regenerates the Copilot side and pauses to ask whenever a Claude feature
can't be translated cleanly. **If you are an AI agent driving `sync`:** show
each printed question to the human, take their answer, feed it to the process
stdin, and continue until `sync` finishes. Never invent answers, press Enter to
skip an unresolved decision, or bypass the wizard by editing generated files by
hand.

Questions you may be asked (saved to `.harness-projection/decisions.json`, so a
clean repo usually syncs silently after the first run):

- **Tool choice** — one Claude tool maps to several Copilot tools; pick which to
  grant. *Asked every sync;* press Enter to keep the current pick.
- **Narrowed tool grant** — a path-scoped grant like `Read(docs/**)`. Choose
  `widen` (drop the limit — may grant more access) or `omit` (grant nothing).
  *Asked every sync.*
- **Unsupported field** — a frontmatter key Copilot doesn't understand. Choose
  `omit`, or `target-native` and supply Copilot fields as JSON.
- **Harness-specific name** — the prompt names a tool that only one harness
  understands. Edit it out, or type `keep` to leave it as written on purpose.
- **Extra capability** — the agent can delegate to sub-agents (or grants all
  tools). Type `ack` to confirm.
- **Extra tool in generated file** — a Copilot-only tool was hand-added to a
  generated file. Type `keep` or `discard`.

## Day to day

- Edit files under `.claude/` only; re-run sync after a change using the
  repository's package-manager command from the table above, or direct Node
  when there is no `package.json`.
- Add the matching `harness-setup:check` command as a CI drift gate
  (non-interactive, exits 1 on drift).
- MCP tools are renamed only: `mcp__<server>__<tool>` → `<server>/<tool>`. Use
  the **same server key** in `.mcp.json` (Claude) and `.vscode/mcp.json` (VS
  Code), or Copilot gets a tool id that matches no registered server.

## Limits — Claude vs Copilot

VS Code and Copilot lack some Claude capabilities. The projection maps what it
can, narrows what it must, and drops what has no equivalent:

- **Dropped** — ~30 Claude tools have no Copilot equivalent and are not granted
  (e.g. `Skill`, `TodoWrite`, `WebSearch`, `Task*`, `Workflow`, `Artifact`).
- **Lossy** — `PowerShell` shares the one terminal tool with Bash; `WebFetch` →
  `web/fetch`; `LSP` → usages + problems.
- **Scoped grants can't be preserved** — a scope like `Bash(npm run *)` can only
  be widened (`widen`) or dropped (`omit`).
- **Skills aren't projected** — they stay in `.claude/skills/`; the tool only
  points Copilot at that same folder.

`node .claude/skills/setup/scripts/harness-projection.mjs --version` prints the
tool version; `sync` and `check` also print it as their first line.
