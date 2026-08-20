# Blueprint: AI Setup for Repositories Using Multiple Harnesses (Copilot + Claude Code)

_Last updated: 2026-08-11_

This blueprint describes how to structure a repository's AI configuration so that it works consistently across GitHub Copilot and Claude Code. Use it when setting up a new repo or improving an existing one.

## Layout

```
repo/
├── AGENTS.md                        # single source of truth for shared instructions
├── CLAUDE.md                        # "@AGENTS.md" + Claude-only extras (often none)
├── .github/
│   ├── copilot-instructions.md      # Copilot-only extras — often absent
│   ├── instructions/                # derived from .claude/rules/
│   ├── agents/                      # derived from .claude/agents/
│   └── skills/                      # optional — only skills for GitHub Copilot code review
└── .claude/
    ├── agents/                      # SOURCE OF TRUTH: agent definitions
    ├── rules/                       # SOURCE OF TRUTH: path-scoped rules
    └── skills/                      # shared — both harnesses read this (requires the VS Code setting below)
```

## VS Code settings (required)

When the team uses VS Code, commit these in `.vscode/settings.json` so everyone gets identical behavior:

- **`chat.useAgentsMdFile` — on.** This is what makes Copilot load AGENTS.md as always-on instructions — the mechanism the whole layout depends on. It's on by default, but pin it explicitly so a user-level override can't silently break the shared-instructions flow.
- **`chat.useClaudeMdFile` — off.** This setting applies only to Copilot (target Local); it controls whether Copilot additionally loads CLAUDE.md as instructions. Keep it off as Copilot already gets the shared instructions from AGENTS.md natively. Claude Code sessions are unaffected — they always read CLAUDE.md through their own harness.
- **`chat.includeApplyingInstructions` — on.** Automatically adds instruction files with a matching `applyTo` pattern to chat requests. Required so that path-scoped rules in `.github/instructions/*.instructions.md` are actually loaded for matching files. Defaults to `true`.
- **`chat.includeReferencedInstructions` — on.** Automatically adds instruction files referenced via Markdown links to chat requests. **This defaults to `false`**, so instruction files that link out to other instruction files won't pull them in unless you enable it — set it to `true`.
- **`chat.agentFilesLocations` — disable `.claude/agents`, keep `.github/agents`.** This prevents Copilot from picking up Claude-format agent files (wrong tool names, silent misbehavior) and from showing duplicate agents in the picker.
- **`chat.instructionsFilesLocations` — disable `.claude/rules`, keep `.github/instructions`.** VS Code reads `.claude/rules/*.md` by default. Disabling `.claude/rules` keeps `.github/instructions` as Copilot's single source of rules.
- **`chat.agentSkillsLocations` — must include `.claude/skills`.** This gives Copilot the same skills folder Claude Code uses, so skills have exactly one home.

```jsonc
// .vscode/settings.json
{
  "chat.useAgentsMdFile": true,
  "chat.useClaudeMdFile": false,
  "chat.includeApplyingInstructions": true,
  "chat.includeReferencedInstructions": true,
  "chat.agentFilesLocations": {
    ".github/agents": true,
    ".claude/agents": false
  },
  "chat.instructionsFilesLocations": {
    ".github/instructions": true,
    ".claude/rules": false
  },
  "chat.agentSkillsLocations": {
    ".claude/skills": true
  }
}
```

## The rules

**1. Shared instructions live in AGENTS.md — only there.**
Both harnesses get it: Copilot discovers root AGENTS.md natively as primary instructions; Claude Code gets it via the `@AGENTS.md` line in CLAUDE.md. The `@` import in Claude Code applies only to the CLAUDE.md file (it cannot be used in agent definitions, skills, rules, etc.) and is executed by the *harness* at launch (deterministic, official Windows-safe replacement for symlinks). `copilot-instructions.md` must NOT restate or link to AGENTS.md — Copilot already loaded it.

Note: The Copilot code review feature *in VS Code* (review selection / uncommitted changes) reads only copilot-instructions.md — not the AGENTS.md (see GitHub's [custom instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support)). This VS Code feature is rarely used; if you need a local code review performed by the AI, it is better to create a dedicated agent for this. (Code review *on GitHub.com* is different: it reads copilot-instructions.md, `.github/instructions/*.instructions.md`, and AGENTS.md, plus any skills defined in `.github/skills`.)

**2. Skills: write only once in `.claude/skills/`.**
Both harnesses read that directory — Copilot does so only when the `chat.agentSkillsLocations` setting in VS Code includes `.claude/skills`. Keep frontmatter to `name` + `description`. Because skills run under multiple harnesses, **write their bodies in terms of actions, not tools** (e.g. "Fetch the content of <url>" rather than "Use WebFetch on <url>"). **If something must be tool-restricted, make it an agent, not a skill.**

**3. Agents: `.claude/agents/` is the single source of truth.**
Claude Code reads these natively. The Copilot equivalents in `.github/agents/` have different tool names in the frontmatter and the `.agent.md` extension. A projection script converts the Claude definitions into the Copilot format — see the `setup` skill's `PROJECTION.md` for how to wire and run it. Edit only `.claude/agents/`; the `.github/agents/` copies are generated and must never be hand-edited. If an agent doesn't need tool restriction, omit `tools:` entirely — both harnesses then allow everything and the two copies are near-identical.

**4. Rules/instructions: `.claude/rules/` is the single source of truth.**
Path-scoped rules live in `.claude/rules/*.md` with a `paths:` frontmatter list; the Copilot equivalents in `.github/instructions/*.instructions.md` use an `applyTo:` string instead. The same projection script converts one to the other; edit only `.claude/rules/`.

**5. Hooks, permissions, and MCP wiring: semantics differ per harness — configure each natively.**
Example: MCP servers are configured for Claude Code in `.mcp.json` at the repo root, and for Copilot in VS Code in `.vscode/mcp.json` — the same server list, but two separate files in each harness's own format. **Server keys must match** (e.g. both use `"exa"`). Agent projection only rewrites tool ids (`mcp__exa__web_search_exa` → `exa/web_search_exa`); it does not read or sync those config files.

Note: MCP servers are also available to GitHub Copilot code review — see GitHub's [example configurations](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/configure-mcp-servers#example-configurations) for setup details.

**6. GitHub.com code review reads skills from `.github/skills/`, not `.claude/skills/`.**
If a skill needs to be available both for development purposes and to GitHub Copilot code review, duplicate it from `.claude/skills/` into `.github/skills/`.

## TL;DR for contributors

- Shared rule? → **AGENTS.md**
- Reusable workflow? → **`.claude/skills/`**
- Specialized agent? → **`.claude/agents/`** (projection script generates `.github/agents/`)
- Path-scoped rule? → **`.claude/rules/`** (projection script generates `.github/instructions/`)
- Never edit `.github/agents/` or `.github/instructions/` directly — changes start in `.claude/`
- Skills for GitHub.com code review? → **`.github/skills/<name>/SKILL.md`**