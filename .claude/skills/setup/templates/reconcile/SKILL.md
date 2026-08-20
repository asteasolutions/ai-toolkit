---
name: reconcile
description: Report the delta between a planned change and what was actually built — deviations, unplanned decisions, whether the result meets the intent, and any docs to update. Use to close out a task before calling it done, whenever a plan or spec was followed; helm's Reconcile phase reaches for this. Especially important after a change that drifted from its plan or made judgment calls the plan did not pin down.
---

# Reconcile

Close the loop by reporting the **delta** — the gap between what was planned and what was built. Nothing else.

A diff already shows *what changed*. Re-narrating it wastes tokens and, worse, breeds false confidence — a self-report of the diff can flatter or mislead. The developer reads the diff for the *what*; they read you for what the diff **hides**: the forks taken, the things not done, the calls made in the dark. Surface only those, so the developer re-examines the delta instead of re-deriving the whole change.

## The ledger

Record exactly these, and stop:

- **Deviations** — where execution left the plan, and why.
- **Decisions** — judgment calls the plan did not pin down: a name, an edge case skipped, an error-handling choice. The most important line, and the easiest to under-report because each call felt obvious when you made it. Re-scan the diff for every choice the plan left open; list them, don't assume none. They are decisions the developer owns but never explicitly made.
- **Verify-against-intent** — does the result satisfy the intent's success criteria? Name the check; do not assert success without one.
- **Doc impact** — default `none`. Escalate only when a durable decision changed the domain model **and** domain knowledge docs already exist. When you escalate, **propose the concrete edit and, once the developer approves, make it** — never merely note that a doc "should" change. Discover the repo's existing form (glossary, decision log, ADR tree, …); do not invent a layout or create new domain-doc trees. This promotes the durable part of the work out of disposable scratch into the committed, shared layer.

If execution matched the plan with no unplanned decisions, the whole reconcile is one line: **"Executed as planned, no deviations."** Resist padding it.

## Then update the program counter

Reconcile is also where the work tree advances:

- Stamp this node's **one-line outcome** into the parent map (`<goal-slug>/_map.md`), so the map carries the whole goal at a glance without the detail. (A single, undecomposed goal has no map — its own Reconcile section is the record.)
- If a deviation or decision **invalidates a downstream task**, say so plainly and flag the affected tasks for re-planning — one surprise must not silently rot the rest of the plan. Reopen only the affected tasks, not the whole decomposition.

The map is the source of truth a fresh context resumes from; leave it accurate.
