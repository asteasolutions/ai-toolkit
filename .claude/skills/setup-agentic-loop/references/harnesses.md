# Harnesses — where the artifacts go and what changes

The **bodies are identical everywhere**. Only frontmatter and file location differ, so write each body once and translate the wrapper per harness. Never fork a prompt: two copies of a reviewer drift, and the drift is invisible until a review passes in one editor and fails in the other.

Install into every harness the repo actually uses. Detect from what is present — `.claude/`, `.cursor/`, `.github/agents/`, or `chat.*` settings in `.vscode/settings.json` — and ask when the answer is not obvious.

## Placement

| | Claude Code | Copilot (VS Code) | Cursor |
|---|---|---|---|
| **Loop skill** | `.claude/skills/agentic-loop/SKILL.md` | reads whatever `chat.agentSkillsLocations` names — point it at the copy that already exists rather than adding another | `.cursor/skills/agentic-loop/SKILL.md` |
| **Agents** | `.claude/agents/<name>.md` | `.github/agents/<name>.agent.md` | `.cursor/agents/<name>.md` |
| **Invocation** | `/agentic-loop` | `/agentic-loop` | `/agentic-loop`; agents are also reachable as `/<name>` |

## Frontmatter

| Field | Claude Code | Copilot | Cursor |
|---|---|---|---|
| `name`, `description` | yes | yes | yes |
| Read-only restriction | `tools:` allowlist | `tools:` allowlist, Copilot ids | `readonly: true` — **but see the wrinkle below** |
| Model | omit; the caller picks the tier | omit | `model: inherit` |
| `disable-model-invocation` | on the skill | ignored | not supported — omit it |

## The read-only wrinkle

A reviewer must be unable to touch source code, yet it **must** write its findings file — that file is the whole channel between review and fix. It also needs git, since a diff is how it sees the slice at all.

- **Claude Code** expresses both exactly: `Write` scoped to the work directory, and `Bash` scoped to the git subcommands it reads with — `Bash(git diff:*)`, `Bash(git show:*)`, `Bash(git log:*)`, `Bash(git status:*)`. Nothing else runs.
- **Copilot** cannot scope a grant. Grant the edit tool and the terminal tool, and rely on the prompt's constraint.
- **Cursor**'s `readonly: true` blocks the findings write too, so it cannot be used here. Omit it and rely on the prompt.

Copilot tool ids for a judging agent: `read/readFile`, `search/textSearch`, `search/fileSearch`, `edit/editFiles` for the findings write, and `runCommands` for git. Claude equivalents are `Read`, `Grep`, `Glob`, `Write`, and the scoped `Bash` entries above.

The terminal grant reads like the larger concession and is not: a Copilot reviewer already holds an unscopeable `edit/editFiles`, so it could already write to source before it had a shell. Both are the same trusted constraint, and neither turns into an enforced one by being withheld — withholding the shell only leaves the reviewer unable to see the diff.

Frontmatter is static, so the grant can only name the work dir — the per-task run directory inside it is chosen at run time. The prompt is what keeps a reviewer inside its own run: it writes the one path it was handed and nothing else.

Where the harness cannot enforce it, the prompt still states it plainly — every reviewer body says it writes nothing but its findings file. Say which harnesses are enforcing and which are trusting when you preview the install; do not present a trusted constraint as an enforced one.

## Resuming an agent

A halt that the developer answers has to get that answer back into a run that is already part-done. Whether the *same* orchestrator can take it depends on the harness:

- **Claude Code** — yes. Each invocation returns an agent id; `SendMessage` to that id or name auto-resumes the instance with its full transcript.
- **Cursor** — yes. Each execution returns an agent id: *"Resume agent abc123 and …"*.
- **Copilot** — **no.** `runSubagent` is stateless: no agent id comes back, and there is no parameter that addresses a prior instance. A second call is a new agent with an empty context. Verified by test — a subagent given a token in one call had no memory of it in the next.

So the loop never *relies* on resumption. The run directory is the continuity mechanism: the orchestrator appends a line to `progress.md` as each slice concludes, and a fresh orchestrator pointed at that directory continues from the first slice that has not landed. Where the harness does support resumption it is an optimisation — cheaper, since the transcript is already warm — never the thing the loop breaks without.

## Delegation depth

The loop needs two layers: the developer's conversation → `orchestrator` → implementer and reviewers.

- **Claude Code** allows three layers below the main conversation by default. A repo or user that sets `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` to `1` breaks the loop; check for it and say so rather than letting the run fail.
- **Cursor** (2.5+) lets the main agent and its direct subagents spawn, but not a third generation. That is exactly the loop's shape — and it means a specialist reviewer can never delegate further, which is fine, since reviewers do their own reading.
- **Copilot** ships nesting **off**: `chat.subagents.allowInvocationsFromSubagents` defaults to `false`, which caps delegation at zero layers below a subagent — the orchestrator launches, then cannot spawn anyone. Setting it to `true` lifts the cap to five. Without it the loop halts at the orchestrator's first delegation, so it is the one editor setting this skill offers to write.

Only the `orchestrator` needs delegation. Every reviewer stays a leaf.

### The Copilot setting, when accepted

Workspace-scoped, in `.vscode/settings.json`:

```json
{
  "chat.subagents.allowInvocationsFromSubagents": true
}
```

**Merge into the existing file; never replace it**, and create it only if the repo has none. Preview the edit like any other write. The grant is per workspace, not per agent — every subagent in the repo gains it, not just the orchestrator — so say that when you offer it. A developer who declines can set the same key in their own user settings; the loop is unrunnable under Copilot until one of the two is in place.
