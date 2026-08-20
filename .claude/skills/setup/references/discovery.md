# Discovery reference — stack and commands

What to read during Explore to fill the `AGENTS.md` Project + Commands layer. Detection is heuristic: fill what you find with confidence; for anything you cannot determine, write `[NEEDS CLARIFICATION: …]` — **never invent a command or a stack claim**. (Composing *declared* commands is not inventing — e.g. a `lint && test` verify built from a declared `lint` and a declared `test` script is fine; "inventing" means writing a command that no declared script, target, or CI step backs.)

## Stack / project overview

Infer the primary stack from the manifest(s) present, and write a single line (what the repo is + its stack):

| Signal | Stack |
|---|---|
| `package.json` | Node/JS or TS (check `devDependencies` for `typescript`) |
| `pyproject.toml` / `setup.py` / `requirements.txt` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml` / `build.gradle` | Java/JVM |
| `Gemfile` | Ruby |
| `composer.json` | PHP |

The repo's own README (first paragraph) is the best source for *what it is*; the manifest gives the stack.

## Commands

Prefer **declared** commands (scripts/targets) over guessed ones — a declared script is what the maintainers actually run.

| Source | Where to look |
|---|---|
| `package.json` | `scripts` — `build`, `test`, `start`/`dev`, `lint` |
| `Makefile` / `justfile` | target names — `build`, `test`, `run`, `lint`, `check` |
| `pyproject.toml` | `[tool.poetry.scripts]`, `[tool.pytest]`; test runner = `pytest` |
| `go.mod` present | `go build ./...`, `go test ./...`, `go vet ./...` |
| `Cargo.toml` present | `cargo build`, `cargo test`, `cargo clippy` |
| CI config (`.github/workflows/*`, `.gitlab-ci.yml`) | the steps CI runs are the authoritative build/test/lint sequence |

**Verify** is the command that proves a change is sound — usually the test command, or a composite the CI runs (e.g. `lint && test`). If unclear, set `[NEEDS CLARIFICATION: verify command]`; the loop's Execute gate depends on it.

A command that **no script, target, or CI step references** probably doesn't apply to this repo — write `none` (e.g. a pure library has no build or run command). Reserve `[NEEDS CLARIFICATION]` for a command that clearly *should* exist but you couldn't pin down.

## Domain knowledge docs

Do **not** seed domain layouts. Discover what already exists and leave it alone:

| Signal | Meaning |
|---|---|
| Existing domain glossaries, context maps, ADR / decision-log trees | Follow them when present |
| Monorepo shape (`packages/*`, `apps/*`, …) with no domain docs | Note the shape; do not invent docs for it |
| Nothing present | Proceed silently — no layout to create |

Skills that need domain language discover docs if they exist. `/setup` never creates them.

## Old-layout signals (migration triggers)

Any of these means a previous `/setup` (or hand-rolled config) used the pre-blueprint layout — propose the matching conversion moves from [`migration.md`](migration.md):

| Signal | Move |
|---|---|
| `.agents/skills/` (or skills anywhere outside `.claude/skills/`) | move skills to `.claude/skills/` |
| `CLAUDE.md` is a symlink | replace with a real file importing `@AGENTS.md` |
| `.claude/skills` is a symlink | remove; skills live in `.claude/skills/` directly |
| `setup:begin/end` region inside `.github/copilot-instructions.md` | remove the pointer region (Copilot loads `AGENTS.md` natively) |
| `.github/instructions/` or `.github/agents/` without `.claude/rules/` / `.claude/agents/` counterparts | stop projection; leave the GitHub-only files untouched and ask the developer to author the desired canonical `.claude/` sources |
