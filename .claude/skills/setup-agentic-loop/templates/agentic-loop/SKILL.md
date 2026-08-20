---
name: agentic-loop
description: Delegated build loop — approve a spec and its slices once, then implementation, verification, and independent review run without you. Type `/agentic-loop <goal>`.
disable-model-invocation: true
---

# Agentic loop

The developer's attention is the scarce resource, and this loop spends it at the **specification** rather than during execution. They approve what is to be built; the work is then written, verified, and judged by a reviewer in a **fresh context**, and they hear from you once.

Reach for it when the goal is well enough understood to specify. When the developer needs to hold the change in their head as it happens, this is the wrong tool — it deliberately takes that away.

> **Invariant: one scheduled interruption.** The front gate below is the only planned stop. After it, the loop reports when it is done — or **halts** and reports when it cannot proceed without guessing.

> **Invariant: this skill never writes code.** It gates and hands off. Implementation belongs to `implementer`, judgement to `reviewer`, sequencing to `orchestrator`.

## 1. Front gate

Everything this task produces lives in **one run directory**: `{{WORK_DIR}}/<goal-slug>/`. Nothing about the task is written anywhere else, and no other task writes into it — one directory the developer can open, read in order, and delete when the task is done.

Slugify the goal and look for that directory first. **It already exists with a spec** → this is a resume: read the spec and `progress.md`, and continue from the first slice that has not landed. Do not re-derive what the record already holds.

Otherwise, produce two things in this conversation, together:

- **A spec** with **numbered clauses** — each one a single checkable statement about behaviour after the change. Clauses are what the reviewer renders a verdict against, so a clause nobody can check is a clause nobody will enforce. If a spec-writing skill is installed, invoke it and number the criteria it produces; otherwise draft the spec here.
- **An ordered slice list** — each slice independently verifiable, and each naming the clauses it satisfies.

Ask about anything you would otherwise guess at, and resolve it before the gate. Every clause of the spec is a thing three agents will act on unattended; an ambiguity that survives this gate is one they will resolve without the developer.

Write both to `spec.md` in the run directory and put them to the developer for approval.

**Criterion:** every clause numbered; every slice mapped to at least one clause; every clause claimed by at least one slice; no unresolved ambiguity; developer approved.

## 2. Hand off

Spawn `orchestrator` with the run directory and the slice list. Run it on a cheap capable tier — it sequences and reads verdicts; it does not write or judge.

Nothing the orchestrator delegates comes back through this conversation. Do not pull findings, diffs, or agent transcripts in here.

**Criterion:** orchestrator spawned with the run directory and the slice list; nothing else read into this conversation.

## 3. Report

Relay the orchestrator's report as it stands: per slice — verify status, verdict, commit — plus non-blocking findings, and, when the run halted, the slice it stopped at and why.

Two things you must never smooth over: a **halt** is not a finish, and a slice the orchestrator reports as machine-unverified was not tested — say so in those terms.

The orchestrator cannot ask the developer anything; asking is yours. When a halt is a question they can answer, put it to them and carry the answer back into the run — never into this conversation as work for you to do. Resume the same orchestrator where the harness can address a prior agent by id, since its transcript is already warm; where it cannot, spawn a fresh one on **the same run directory**. Either way it reads `progress.md` and continues from the first slice that has not landed, so the slices that passed are not built again.

Point them at the run directory — the spec, every findings file, and every verdict are sitting there to be read. The report is a summary of that record, not a replacement for it.

**Criterion:** every slice's verify status and verdict relayed; any halt named as a halt; the work dir named; the next move left to the developer.
