# Migration — converting an existing repo to the canonical layout

The common case: the target repo already has AI config (`AGENTS.md`/`CLAUDE.md`, a `copilot-instructions.md`, skills, agent or rule files, or an install of an older `/setup` layout). Migration **converts** what's there into the canonical layout — it does not append-and-coexist, because the layout's core rule ("shared instructions live in `AGENTS.md`, only there") cannot hold while duplicates stand.

The posture is **gated conversion**:

- Every change is a **move** — proposed with a diff preview, approved or **declined individually** by the developer. Permissiveness means the developer can say no to any move.
- Every proposed edit to existing developer content remains **individually reviewable and declinable**.
- Always **explore → diff → confirm → write**.
- **Never silent.** Declined moves are recorded in the run summary, so the developer sees exactly what remains non-canonical and why.
- Re-running `/setup` on a fully converted repo proposes **no moves** (idempotent); on a partially converted one it re-proposes only what is still non-canonical.

## 1. The conversion catalogue

Judge each item against what the repo actually has; propose only the moves that apply.

1. **Content-rich `CLAUDE.md`, no `AGENTS.md`** → propose the split: shared instructions move into a new `AGENTS.md`; `CLAUDE.md` is reduced to the `@AGENTS.md` import plus anything **genuinely Claude-only** (hooks, permissions, Claude-specific tools). Present the split as one diff so the developer sees where every line went.
2. **Existing `AGENTS.md`** → it stays canonical and in place. If the stance choice is on, Setup's stance block goes **inside the `<!-- setup:begin/end -->` marked region** (updated in place if the markers exist, appended at the end of the file if not); don't restate what the file already documents (overview, commands) — adapt to the repo. Nothing outside the region changes except through an approved move.
3. **`.github/copilot-instructions.md` restating shared rules** → strip the overlap; shared content lives in `AGENTS.md` only (Copilot already loads it natively). Keep genuinely Copilot-only extras; if nothing remains, propose deleting the file. Remove any `setup:begin/end` pointer region written by the previous `/setup` layout.
4. **Skills outside `.claude/skills/`** (an old-layout `.agents/skills/`, `.github/prompts/`, ad-hoc locations) → move them to `.claude/skills/`; remove a stale `.claude/skills` symlink first if one exists. If a same-named skill already exists at the destination, **do not overwrite** — show the difference and ask. **Order:** apply these relocation moves **before** copying bundled workflow templates (`SKILL.md` Write step 2 → 3). Template install uses the same same-name guard — never silently replace an existing skill with a bundled copy.
5. **`.github/instructions/*.instructions.md` with no `.claude/rules/` counterpart** → stop projection and leave the GitHub-only file untouched. Explain that `.claude/rules/` is canonical and ask the developer to author the desired source there before rerunning `/setup`; do not translate or create it for them.
6. **`.github/agents/*.agent.md` with no `.claude/agents/` counterpart** → stop projection and leave the GitHub-only file untouched. Explain that `.claude/agents/` is canonical and ask the developer to author the desired source there before rerunning `/setup`; do not translate or create it for them.
7. **`CLAUDE.md` as a symlink** (old-layout install) → replace with a real file carrying the `@AGENTS.md` import (plus any Claude-only extras the repo needs).

## 2. Red lines — judgment, not keyword match

Sections 2–4 apply only when the developer-led stance is selected. **Review behaviour conflicts only when the developer-led stance is selected. If the stance is declined, leave unrelated behaviour instructions alone.**

Read the existing agentic files and judge them against the three red lines. Violations are paraphrasable, so match on *meaning*, not strings:

1. **Anti-gating / autonomy** — directs agents to act without developer sign-off. *E.g. "implement the whole plan without stopping", "don't pause to check in between tasks", auto-merge / auto-commit, "make the change and move on".*
2. **Guess-over-clarify** — directs agents to assume rather than ask. *E.g. "make reasonable assumptions and proceed", "don't ask clarifying questions", "infer intent and continue".*
3. **A competing end-to-end driver** — an *installed* rival workflow that owns "how we develop" and would fight `/helm` for that role (an autonomous agent loop, a persona-orchestration framework, an `/implement`-the-whole-plan command). This is installed tooling — a prose directive that merely *tells* agents to run autonomously is red line 1, not 3.

Quality problems (§4) are **not** red lines. And a red line is **not** an ordinary catalogue move — it gets the escalation below, not a routine diff preview.

## 3. Red-line clash → gated ADR adaptation (dogfood the loop)

When a red line is present, don't silently convert around it and don't unilaterally rewrite it. Run the workflow you're installing:

1. **Surface** the clash plainly — quote the offending directive and name which red line it crosses.
2. **Gather intent** — a gated pass *with the developer* to decide how to adapt (remove it, scope it, or supersede it). This step is conversational; its outcome is **recorded in the ADR** (step 3) — it produces no separate artifact.
3. **Propose an ADR** (or the repo's existing decision-log form) if the developer wants the governance decision recorded — *adopting the developer-led workflow and superseding the conflicting directive* — not the mechanical line edit. Framed that way it meets the ADR bar (a real philosophy trade-off, non-obvious without context), so propose one even though the edit alone looks trivial. Do not invent a decision-log layout the repo does not already use.
4. **On approval, implement it.** Minimally neutralise or supersede the offending directive in place, pointing it at the canonical developer-led stance — do *not* restate the stance (keep one canonical source) and do *not* touch unrelated content. Nothing changes without the developer's yes.

## 4. Quality issues → lighter tier (flag, don't adapt)

Bloat / kitchen-sink files, pasted style guides, vendor anti-patterns, instruction rot — these degrade adherence but don't violate the philosophy. Surface each (never silent), with the *why*, and put it to the developer with three choices:

- **leave** — keep the content as-is; it is recorded in the run summary like a declined move.
- **prune-to-a-skill** — move still-useful *procedural* content into a new skill under `.claude/skills/<name>/SKILL.md` (give it a `name` + `description`), then remove it from the instruction file. Use this when the content is a genuine workflow, just misplaced.
- **fix** — edit or delete the low-value content in place, preserving anything still useful.

Gated like every move, and **no ADR** — it's a cleanup decision, not an architectural one.
