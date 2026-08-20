# Detection — fitting the loop to this repo

Resolve every row before previewing anything. Prefer evidence in the repo over convention, and convention over asking; ask rather than guess.

| What | How to resolve | Fallback |
|---|---|---|
| **Harnesses in use** | `.claude/`, `.cursor/`, `.github/agents/`, or `chat.*` settings in `.vscode/settings.json`. More than one is normal | Ask the developer which editors the team uses |
| **Agents and skills homes** | Per harness — see [`harnesses.md`](harnesses.md). Where one harness's files are generated from another's, write to the source, never to generated output | The conventional home for each detected harness, stated as a fallback in the preview |
| **Work dir** (`{{WORK_DIR}}`) | Always inside the repo, under `.scratch/` — reuse the repo's existing sub-layout if one is visible, else `.scratch/agentic-loop/` | `.scratch/agentic-loop/` |
| **Verify command** (`{{VERIFY_COMMAND}}`) | The repo's shared instruction file, if it lists commands → declared scripts (`package.json`, `Makefile`, `justfile`, `pyproject.toml`, `Cargo.toml`) → CI workflow steps | Ask the developer |
| **Diff scope** | How a reviewer sees a slice: it runs `git diff` itself against a **baseline tree** the orchestrator captured with `git write-tree` before the slice ran. The orchestrator stages before diffing, so files the slice added are in it; scoped to the slice under either commit mode | — |
| **Generated agent mirrors** | Whether tooling in the repo projects agent files into a second harness's format | Report as absent; the loop runs regardless |
| **Spec source** | A spec-writing skill in the skills home | The `agentic-loop` skill drafts the spec itself |

## Triggers

Every specialist declares a **trigger** the orchestrator evaluates against a slice's diff. Two kinds, and most specialists need only the first:

- **Path trigger** — globs. Right for surfaces that live somewhere: migrations, schemas, infrastructure.
- **Diff signal** — a property of the change itself, for concerns that have no single home. Right for the bundled specialists, whose subject is what a change *does*, not where it lands.

Resolve triggers from the repo, and prefer a narrow trigger you can justify over a broad one that fires on everything — a specialist that reviews every slice is one the developer learns to ignore.

**`security-reviewer`** — fires on paths that handle input the repo does not control (request handlers, routes, controllers, deserializers, file and command execution), on authentication and authorization code, and on changes to dependency manifests. Name the actual directories in this repo, not generic ones.

**`architecture-reviewer`** — fires on structural signals: a new module or package directory, a new import crossing a boundary the repo otherwise keeps, a change to a dependency manifest, or a new exported interface, endpoint, or schema. In a repo with no visible boundaries to defend, say so and recommend declining it.

## Proposing repo-specific specialists

Beyond the bundled two, a specialist earns its place only when the repo has a surface where a generic reviewer predictably misses things *and* the surface is visible as a path. Each proposal carries three parts:

- **Evidence** — the path that proves the surface exists (`db/migrations/`, `openapi.yaml`, `terraform/`).
- **Trigger** — globs matching that surface.
- **Focus** — the one or two failure modes it exists to catch (irreversible migration, contract break).

No evidence path, no proposal. Each is accepted or declined separately, and declining all of them is a normal outcome — the base reviewer covers every slice regardless.

## Keeping the work dir out of git

Specs and findings stay **in the repo**, never in a temp directory: they are the record of what the loop decided, and the developer must be able to open them mid-run, after a halt, and when a verdict looks wrong.

So check that `.scratch/` is ignored, and add it when it is not — creating `.gitignore` only if the repo has none. Preview that edit like any other. If the developer would rather commit the artefacts, leave `.gitignore` alone; the loop works either way.

## Out of scope

Creating or restructuring shared instruction files or editor settings; installing other workflow skills; configuring cross-harness projection. This skill adds a loop to a repo and adapts to whatever layout it finds. Three exceptions, all narrow: the `.gitignore` entry above, appending a discovered verify command to a commands section that already exists, and — under Copilot, with the developer's yes — the one settings key that makes delegation possible at all (`harnesses.md`).
