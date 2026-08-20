# Work-tree artifacts

All work lives under `.scratch/<goal-slug>/`. Gitignored by default; if the repo is configured for committed work docs, write there instead. These docs are the program counter — keep them well-formed, because a fresh context trusts them as truth.

The work tree is always a directory, `.scratch/<goal-slug>/`. An undecomposed goal holds a single leaf doc, `task.md`; a decomposed goal adds `_map.md` plus one doc per task.

## Leaf task — `<goal-slug>/<task-slug>.md` (an undecomposed goal: `<goal-slug>/task.md`)

```markdown
# <task title>

## Intent
<what + why, in the developer's terms>

### Current state (orientation digest)
<what the agent understood about the existing code, and what it read to form that view>

<!-- [NEEDS CLARIFICATION: …] markers live inline wherever uncertainty sits; they block every gate until removed -->

## Plan
<the spec: what/why · test seams (how it will be verified) · implementation decisions · behaviour-level `done` criteria. No brittle file paths or code — paths emerge in Execute. A decision-encoding prototype (schema, type, state machine) may be inlined when the shape *is* the decision.>

## Reconcile
<delta-only: Deviations · Decisions · Verify-against-intent · Doc impact. One line if clean.>
```

A node carries only the sections its phase has reached — Capture writes Intent, Plan adds Plan, Reconcile adds Reconcile.

## Parent map — `<goal-slug>/_map.md` (decomposed goals only)

The map is a **map, not a container**. It holds the overarching intent and the task list with status and a one-line outcome per finished task — never the tasks' detail (that lives in each task doc, loaded only when that task runs).

```markdown
# <goal title>

## Intent
<overarching what + why>

## Tasks
1. [done] <task-slug> — <one-line outcome stamped by Reconcile>
2. [in-progress] <task-slug>
3. [pending] <task-slug> — blocked by: 2
```

Reading the map gives the whole goal at a glance; that glance is how the developer holds the whole while any single context holds only a part.
