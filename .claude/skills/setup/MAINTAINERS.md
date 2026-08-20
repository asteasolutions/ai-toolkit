# Maintaining the `setup` skill

> Notes for maintainers of this skill. Not part of running `/setup` — `SKILL.md` deliberately omits this so it isn't misread when the skill is copied into another repo.

## What counts as the "home repo"

There is no flag marking the home repo. **Home is, by definition, the repo where the nine canonical core skills (`helm`, `grill-me`, …) live as siblings of this `setup` skill** under `.claude/skills/`. Everywhere else, `templates/` is the source of truth and there is nothing to maintain.

## The setup bundle is derived

`/setup` carries two generated inputs so it works without network access or repository-local documentation:

- `templates/` comes from the nine canonical live sibling skills.
- `references/blueprint.md` comes from the canonical `docs/ai-repo-setup-blueprint.md`.

Do not edit either generated copy directly. After editing a canonical source, resync the bundle:

```sh
npm run setup-bundle:sync
npm run setup-bundle:check
```

`sync-setup-bundle.sh` **self-determines**: it checks for the live sibling skills and canonical blueprint, then refuses with a clear message when run outside the home repo rather than guessing.

The tracked `.husky/pre-commit` hook checks both the working tree and the staged snapshot, so a canonical change cannot be committed without its generated copy. Husky enables it through the `prepare` script when dependencies are installed:

```sh
npm install
```

## The bundled harness-projection CLI is a derived copy

The source of truth for `scripts/harness-projection.mjs` is the sibling
`harness-projection/` package at the repository root. After changing that
package, rebuild the copy that travels with `/setup`:

```
npm run build --prefix harness-projection
```

That single build writes the byte-identical artifact to both
`harness-projection/dist/harness-projection.mjs` and
`.claude/skills/setup/scripts/harness-projection.mjs`. The harness-projection
test suite compares both outputs with a fresh rebuild:

```
npm test --prefix harness-projection
```
