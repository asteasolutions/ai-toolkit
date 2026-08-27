---
name: grounded-research
description: Grounded research. Traceability-first research workflow for evidence, reliability, product, policy, technical, sentiment, complaint, review, public-opinion, and source-backed questions. Use when the user asks for grounded research, rigorous research, exact source traceability, text fragment links, citations, verification, fact-checking, adversarial review, counterevidence, confidence labels, source hierarchy, or a claim-to-source evidence map. Also use when another skill needs source-backed claims checked against primary sources, current product/tool information, community sentiment, or contested evidence.
---

# Grounded research

## Leading word: audit

Run research as an **audit**: every conclusion must trace to exact evidence, survive a counter-case, and expose its weak spots. The goal is not maximal length; the goal is a source-backed answer the user can inspect.

Load a reference only when it applies:

- `references/web.md` — evidence is on the web.
- `references/codebase.md` — evidence is in a repo or local files.

For hybrid tasks load both branch files and keep web receipts separate from local receipts.

## Step 1: Classify the branch and depth

Choose both a branch and a depth before researching. State the assumption only when it affects interpretation.

### Branches

- **Evidence branch**: what is true, likely true, safest, best supported, most reliable, or most accurate.
- **Opinion branch**: what people think, user sentiment, complaints, reviews, Reddit/X/forum reactions, or community experience.
- **Product/tool branch**: whether to adopt, compare, trust, buy, configure, or rely on a tool, model, library, service, API, device, or workflow.
- **Policy/legal/medical/financial branch**: current rules or high-stakes guidance. Use current primary sources and disclose jurisdiction or scope limits.

### Depths

- **Light audit**: simple fact-check, single narrow claim, or low-stakes answer. Use at least one strong source; include countercheck only if obvious.
- **Standard audit**: default for research. Use primary sources when available, one or more independent corroborating sources, an adversarial check, and concise confidence labels.

Completion criterion: branch and depth are chosen, and the evidence plan matches the user’s stakes instead of forcing every answer into the heaviest format.

## Step 2: Researcher pass

Build the strongest source-backed answer. A **material claim** is one that affects the answer's conclusion, confidence, recommendation, or interpretation.

- Among sources in the same tier, prefer ones that support exact passage links, especially text fragment links. Never pick a weaker source because it has a fragment link.
- Use current sources when facts may have changed.
- Capture only evidence that directly supports or weakens a material claim.
- Separate **findings** from **interpretation** and **recommendation**.
- Track non-fragment links, unavailable primary sources, old sources, missing jurisdictions, missing versions, and uncertainty.

### Source hierarchy by branch

**Evidence branch**
1. Primary sources: official docs, filings, laws, standards, papers, datasets, direct announcements.
2. Reputable expert or industry sources.
3. Independent corroborating sources.
4. Social/community sources as signals only.
5. Weak SEO posts or anonymous unsupported claims. Avoid for conclusions.

**Opinion branch**
1. High-engagement Reddit/X/forum/review discussions with repeated agreement or comparable reports.
2. Multiple independent community threads showing the same pattern.
3. Surveys, polls, ratings, or aggregated review data.
4. Reputable reporting about public reaction.
5. Isolated low-engagement anecdotes. Mention only as anecdotes, not representative evidence.

**Product/tool branch**
1. Official docs, changelogs, release notes, pricing pages, security pages, API docs.
2. Repository evidence: issues, PRs, commits, releases, maintainer comments, license files.
3. Independent benchmarks, reproducible evaluations, incident reports, security advisories, teardown posts.
4. Practitioner writeups with concrete tests, configs, or failure modes.
5. Community sentiment as adoption/friction signal, not proof of capability.

Marketing copy is not proof of capability. Downgrade confidence when evidence is vendor-only, outdated, unverifiable, benchmark-only, or from one narrow workflow.

Completion criterion: each material initial conclusion has direct evidence, a source label, and a preliminary confidence level.

## Step 3: Adversarial pass

Do not run this pass yourself.

Use the harness's sub-agent tool. ALWAYS use the `adversarial-reviewer`, NEVER a generic subagent. Do the pass inline only when this harness has no sub-agent tool or `adversarial-reviewer` doesn't exist — and say so before you start.

The dispatch prompt is self-contained. The reviewer shares none of your context. Include:

- the user question;
- branch and depth;
- each material conclusion;
- the evidence and citations used;
- preliminary confidence.

Tell it to attack those conclusions and to return only the headed sections in its agent brief.

Completion criterion: the strongest counter-case has been considered, and every surviving conclusion is either unchanged, narrowed, weakened, or rejected.

## Step 4: Judge and synthesize

Resolve the audit from the researcher pass and the `adversarial-reviewer` output. Do not re-run the attack. Do not average both sides.

- ALWAYS primary over secondary.
- ALWAYS direct evidence over commentary.
- ALWAYS current evidence for changing topics.
- ALWAYS independent corroboration over repeated claims.
- ALWAYS transparent methodology over vague assertions.
- NEVER let a lower-tier source override a stronger source without explaining why.
- Make uncertainty visible.

Completion criterion: final claims are no stronger than the evidence allows.

## Citation rules

Use the most precise working link available for every material claim.

Citation labels:

- **Text fragment link**: opens directly to the exact highlighted passage. Preferred.
- **Anchor link**: opens to a section or heading, not exact highlighted text.
- **Plain link — not text fragment**: opens only to the page/source.
- **Social signal**: Reddit/X/forum/review evidence with meaningful engagement, agreement, repetition, or explicit user interest in opinion evidence.

Never fabricate text fragments. Never call a link a text fragment unless it uses a working text fragment. If text fragments are unavailable, label the limitation.

## Final answer format

Choose the lightest format that preserves auditability.

### Light audit format

1. **Bottom line**
2. **Evidence**
3. **Caveat / confidence**

### Standard audit format

1. **Mode**: branch and depth, when useful.
2. **Bottom line**: direct answer with confidence.
3. **Findings**: source-backed facts only.
4. **Adversarial check**: strongest challenge, concession, and resolution.
5. **Evidence map**: use when there is more than one substantive conclusion.
6. **Gaps**: missing evidence or limits.


## Evidence map

Use this table for standard audits with multiple conclusions:

| Claim / conclusion | Evidence used | Link type | Adversarial result | Confidence |
|---|---|---|---|---|
| Claim A | Source 1, Source 2 | Text fragment links | Survived challenge | High |
| Claim B | Source 3 | Anchor link | Narrowed by version/scope | Medium |
| Claim C | Community threads + reviews | Social signal | Supported as sentiment only | Medium |

Confidence labels:

- **High**: strong primary evidence or multiple reputable independent sources agree; adversarial pass found no serious weakness.
- **Medium**: good evidence exists but is incomplete, indirect, partly interpretive, mildly contested, or version/scope-sensitive.
- **Low**: limited, indirect, conflicting, old, or heavily community-dependent evidence.
- **Insufficient evidence**: the claim cannot be responsibly supported.

## Output discipline

- Do NOT present uncited material claims as evidence.
- Do NOT bury source weaknesses.
- Do NOT use isolated low-engagement social posts to support a conclusion.
- Do NOT overstate social evidence unless the branch is opinion research.
- Do NOT include a large evidence map when a light answer answers the user better.
- Keep visible reasoning compact; show enough of the audit to make the answer inspectable, not every private step.
