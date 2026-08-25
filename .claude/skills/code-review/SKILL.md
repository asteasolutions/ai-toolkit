---
name: code-review
description: GitHub Copilot code review using thermo-nuclear correctness and code-quality rubrics. Use for pull request review, branch diffs, and review of added or modified code.
---

# Copilot Code Review

When reviewing this change, apply BOTH of the following skills as complete rubrics. Do not skip either pass.

1. **thermo-nuclear-review** - bugs, breaking changes, security issues, developer-experience regressions, and feature-gate leaks. Only added or modified code.
2. **thermo-nuclear-code-quality-review** - code-judo / structural simplification, 1k-line file growth, spaghetti branching, boundaries, and abstraction quality.

If those skills are not already in context, load them by name from sibling skill directories. If they cannot be loaded, still run both passes using the same intent: a harsh correctness/security audit of the diff, then a harsh maintainability audit of the same diff.

Apply any repository instructions (`AGENTS.md`, `.github/copilot-instructions.md`, path-specific `*.instructions.md`) as constraints on findings and remediations. Those files are the source of repo-specific policy. This skill is not.

## Workflow

1. Determine review scope from the PR, branch, or changed files. Gather the diff and enough surrounding file context to evaluate the change without guessing.
2. Apply the correctness/security rubric to the diff. Trace cross-module side effects. Do not report pre-existing issues in untouched code. Do not present unfinished research when the related code is in this repository.
3. Apply the code-quality rubric to the same diff. Search for structural simplifications, not just local cleanup.
4. Synthesize one review. Findings first, deduplicated across both passes. Weight overlapping findings more heavily. Resolve disagreements with your own judgment. Keep summaries brief.

## Output

Prefer a small number of high-conviction comments over a long list of nits.

Priority order:

1. Correctness, breakage, and security
2. Structural code-quality regressions and missed code-judo simplifications
3. Spaghetti / branching complexity, boundary leaks, file-size explosions
4. Remaining maintainability issues that still matter

For each finding include file references, evidence, and a concrete remediation that fits this repository's instructions. Do not rubber-stamp "it works" if the change makes the codebase messier or leaves an obvious simpler structure unused.

Calibrate severity honestly. Do not inflate nits into blockers. Do not downgrade real defects.
