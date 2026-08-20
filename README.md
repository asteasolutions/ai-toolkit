# ai-toolkit

Reusable agent **skills** and **agents** for Claude Code and GitHub Copilot.

## Skills

Browse `.claude/skills/` for what each one does, or run the `--list` command below.

### Install

Install every skill in this repository:

```bash
npx skills add asteasolutions/ai-toolkit -a claude-code --copy
```

- `-a claude-code` targets that harness only.
- `--copy` writes real files instead of symlinks.

Skills land in `.claude/skills/`. That single install serves **both** harnesses: Claude Code
reads that directory natively, and Copilot reads it too once VS Code is configured (below).

Other useful invocations:

```bash
# see what's here, install nothing
npx skills add asteasolutions/ai-toolkit --list

# install a single skill
npx skills add asteasolutions/ai-toolkit --skill tdd -a claude-code --copy
```

### GitHub Copilot in VS Code

Point Copilot at the same directory by adding to the repository's `.vscode/settings.json`:

```json
{
  "chat.agentSkillsLocations": {
    ".claude/skills": true
  }
}
```

## Agents

The `skills` CLI installs skills only, so agents are copied by hand. Both harness formats ship
here — pick the one matching your tool:

```bash
# Claude Code
cp .claude/agents/ai-researcher.md <your-repo>/.claude/agents/

# GitHub Copilot
cp .github/agents/ai-researcher.agent.md <your-repo>/.github/agents/
```

## Contributing

The contents of this repository are overwritten on each release, so
**pull requests here will not be merged** — a merged change would be erased by the next publish.

Bug reports and suggestions are welcome as **issues**.
