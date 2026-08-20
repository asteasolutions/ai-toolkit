# Agent Instructions

Always-on guidance for any AI agent working in this repo, shared across harnesses (GitHub Copilot, Claude Code). This is the **canonical** instruction file — keep it concise, stable, and factual.

## Project

{{PROJECT_OVERVIEW}}
<!-- fill: One line: what this repo is + its primary stack. Filled at setup from the repo's manifests.
     If it could not be determined, leave: [NEEDS CLARIFICATION: one-line project overview + stack] -->

## Commands

The commands an agent needs to build, run, and **verify** changes — a change is not done until the verify command passes. These are the one piece of volatile content that earns a place here, because every task depends on them; keep them current.

- **Build:** {{BUILD_CMD}}
- **Test:** {{TEST_CMD}}
- **Run:** {{RUN_CMD}}
- **Lint:** {{LINT_CMD}}
- **Verify (must pass before a change is done):** {{VERIFY_CMD}}
<!-- fill: Fill each from the repo's manifests. If a command genuinely does not apply, write "none".
     If it should exist but could not be determined, write [NEEDS CLARIFICATION: <which command>].
     Never invent a command. -->

<!-- fill: everything below is Setup's optional stance block. Omit it entirely if the choice is declined.
     The setup:begin/end markers are load-bearing delimiters — keep them. -->
<!-- setup:begin -->
## Working stance — developer-led

The developer owns every technical decision. You sequence and gate; you never decide for them.

- **Gate decisions, scaling ceremony to risk.** Surface a technical decision and get a call before acting on it. A trivial, reversible step needs only a light touch; a structural or hard-to-reverse one gets a full stop. Don't drown small asks in ceremony — and don't slip big ones through.
- **Eliminate uncertainty before acting.** When something is ambiguous, ask — don't guess. Mark an unresolved point `[NEEDS CLARIFICATION: …]` and resolve it before building on top of it.
- **Keep the developer oriented.** Work so they can hold an accurate mental model of what is happening — including *during* execution. Report what changed, and the calls you had to make in the dark.

For any substantial task, drive it through the developer-led loop: type **`/helm <goal>`** (capture intent → plan → execute → reconcile). `/helm` is the structured, full-ceremony form of the stance above.
<!-- fill: include the /helm sentence above only when the workflow skills are installed. -->

## Keeping this file healthy

- **Content discipline.** Only always-on, broadly-applicable guidance belongs here. Procedures and multi-step workflows live in skills under `.claude/skills/`, loaded on demand. For each line, ask: *would removing it cause an agent to make a mistake?* If not, cut it.
- **Self-improvement — so the harness can't hit the same wall twice.** When something breaks (a failed command, a denied permission, a misleading instruction) and it happens a *second* time, fix the cause: propose the smallest change, confirm it, apply it. Route the fix to the right surface — a hook, a skill, a config, or this file — not reflexively here.
- **One canonical source.** This file is the single source of always-on instructions. Copilot loads it natively (`chat.useAgentsMdFile`); Claude Code imports it via the `@AGENTS.md` line in `CLAUDE.md`. Don't copy guidance between harness files.
<!-- setup:end -->
